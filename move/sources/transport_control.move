#[allow(unused_field, unused_use)]
module dtp::transport_control {

    // Code order guideline? (WIP - still learning):
    //    use (std, sui, other, dtp)
    //    { friend }
    //    ============ structs ================
    //    struct+accessors
    //    init
    //    friend or private new, delete
    //    =============== Public =====================
    //    public entry create (if applicable)               More Accessible
    //    public entry destroy (if applicable)                   |
    //    Other public entry                                     |
    //    Other public                                           |
    //    Other public(friend)                                   |
    //    ============== Private =====================           V
    //    private struct+accessors                         
    //    private new, delete
    //    Other private                                    Less Accessible
    //    ================ Tests =====================
    //    Unit Tests

    use std::option::{Option};

    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    
    use sui::transfer;

    use dtp::service_type::{Self};
    use dtp::errors::{Self};
    use dtp::weak_ref::{Self,WeakRef};
    use dtp::host::{Self,Host};
    use dtp::conn_objects::{Self,ConnObjects};

    #[test_only]
    friend dtp::test_transport_control;


    // Control Plane of a connection.
    //
    // Shared object
    //
    // Authorized Callers: 
    //   - Connection Initiator (Client)
    //   - Host owner (Server)
    //    
    struct TransportControl has key, store {
        id: UID,

        flags: u8, // DTP version+esc flags always after UID.
        
        service_idx: u8, // UDP, Ping, HTTPS etc...

        // Hosts involved in the connection.        
        cli_host: WeakRef,
        srv_host: WeakRef,
        
        // Some call authorization verified with sender ID address.
        cli_addr: address,
        srv_addr: address,

        // Connection Type.
        //
        // TODO Bi-directional, uni-directional or broadcast. Always bi-directional for now.

        // Keep track of the related Pipes.
        //
        // Intended for slow discovery.
        //
        // It is expected that DTP off-chain will cache these IDs.
        cli_tx_pipe: WeakRef,
        srv_tx_pipe: WeakRef,
    }


    // Constructors

    public(friend) fun new( service_idx: u8,
        cli_host: &Host,
        srv_host: &Host,
        conn: &mut ConnObjects,
        ctx: &mut TxContext): TransportControl
    {
        // Check service_idx is in-range.        
        assert!(service_idx < service_type::SERVICE_TYPE_MAX_IDX(), errors::EServiceIdxOutOfRange());
        
        // If address are same, then the host ID must be the same, else the host ID must be different.
        /*
        if (cli_addr == srv_addr) {
            assert!(cli_host == srv_host, errors::EHostAddressMismatch1());
        } else {
            assert!(cli_host != srv_host, errors::EHostAddressMismatch2());
        };*/

        // Verify that at least one pipe is provided._
        /*
        let is_client_tx_pipe_set = weak_ref::is_set(&cli_tx_pipe);
        let is_server_tx_pipe_set = weak_ref::is_set(&srv_tx_pipe);
        assert!(is_client_tx_pipe_set || is_server_tx_pipe_set, errors::EOnePipeRequired());
        */

        // If two pipes are provided, they must be different objects.
        /*
        if (is_client_tx_pipe_set && is_server_tx_pipe_set) {
            let pipe1 = weak_ref::get_address(&cli_tx_pipe);
            let pipe2 = weak_ref::get_address(&srv_tx_pipe);
            assert!(pipe1 != pipe2, errors::EPipeInstanceSame());
        };*/

        let tc = TransportControl {
            id: object::new(ctx), 
            flags: 0,
            service_idx,
            cli_host: weak_ref::new_from_obj(cli_host),
            srv_host: weak_ref::new_from_obj(srv_host),
            cli_addr: host::authority(cli_host),
            srv_addr: host::authority(srv_host),
            cli_tx_pipe: weak_ref::new_empty(),
            srv_tx_pipe: weak_ref::new_empty()
        };

        // Initialize the Weak references (for slow discovery).
        tc.cli_tx_pipe = dtp::pipe::new_transfered(object::borrow_id<TransportControl>(&tc), 
                                                    2, tc.cli_addr, true, conn, ctx);
        tc.srv_tx_pipe =  dtp::pipe::new_transfered(object::borrow_id<TransportControl>(&tc),
                                                    2, tc.srv_addr, false, conn, ctx);
        
        // Update the ConnObjects (returned to the end-points when a connection is completed).
        conn_objects::set_cli_tx_pipe(conn, weak_ref::get_address(&tc.cli_tx_pipe));
        conn_objects::set_srv_tx_pipe(conn, weak_ref::get_address(&tc.srv_tx_pipe));

        tc
    }


    public(friend) fun delete( self: TransportControl ) {
        let TransportControl { id, flags: _,
          service_idx: _,
          cli_host: _, srv_host: _,
          cli_addr: _, srv_addr: _,
          cli_tx_pipe: _, srv_tx_pipe: _,          
        } = self;


        object::delete(id);
    }    

    // Read accessors
    public(friend) fun srv_addr(self: &TransportControl): address {
        self.srv_addr
    }

    public(friend) fun cli_addr(self: &TransportControl): address {
        self.cli_addr
    }

    // Initial Inner Pipe address.
    // This is for the first response toward the client.
    public(friend) fun ipipe_addr(self: &TransportControl): address {
        weak_ref::get_address(&self.srv_tx_pipe)
    }

    // The TransportControl is the shared object for the
    // connection between two hosts.
    //
    // It is created by the client and provides also unique capabilities
    // to the server.
    //
    // There are two ways of creating a TransportControl:
    //
    //    best_effort:
    //        Created without checking for approval with the server Host
    //        object first.
    //
    //    with_preapproval:
    //        Created with an approval obtain from the server Host. The
    //        approval must be used within 1 whole epoch (~24 hours).
    //
    // Pre-approval is mandatory for some server, so the success of the connection
    // depend on following the proper procedure in the first place.
    //
    // A pre-approval is not a guarantee of service (the server might go down between
    // the pre-approval and using it), but DTP decentralized logic attempts to keep
    // the expectation realistic (base on recent server stats) that the service will be
    // available.
    //
    // Best-effort has very little control and could fail or be decline in case of 
    // a server being too busy. At worst, the server is not going to respond to the 
    // connection request and the client will have wasted gas attempting to connect.
    //
    // Pre-approved Service is a more controlled approach where the connection is
    // "guaranteed" to have dedicated ressources (no oversubscribing). It is more 
    // appropriate in circumstance where there is an off-chain business relationship.
    //
    // Returns:
    //    - tc_address: TransportControl address. Most other addresses can be learn from it.
    //    - cli_tx_ipipe: First InnerPipe used by client to TX to server.
    //    - server_tx_ipipe: First InnerPipe used by server to TX to client.

    #[allow(lint(share_owned))]
    public fun create_best_effort( service_idx: u8,
                                   cli_host: &mut Host,
                                   srv_host: &Host,
                                   conn: &mut ConnObjects,
                                   ctx: &mut TxContext )
    {
        // Sender must be the owner of the cli_host.    
        assert!(host::is_caller_authority(cli_host, ctx), errors::ENotClientHostAuthority());

        // Create the TransportControl/Pipes/InnerPipes
        //
        // A "Connection Request" event is emited. The server may choose to 
        // accept the connection, ignore the request or pro-actively
        // refuse the request (which is relatively nice since it save the 
        // client some storage fee by allowing to delete the object created).
        //
        // Temproary remove for testing.
        let tc = dtp::transport_control::new(service_idx, cli_host, srv_host, conn, ctx);
        conn_objects::set_tc(conn, object::id_to_address( object::borrow_id<TransportControl>(&tc) ));

        // Emit the "Connection Request" Move event.
        // The server will see the sender address therefore will know the TC and plenty of info!        
        dtp::events::emit_conn_req( service_idx, *conn );
        transfer::share_object(tc);

        // TODO Add the TC address to the Client Host object registry (for slow discovery).        
    }

    public entry fun create_preapproved( _ctx: &mut TxContext ) 
    {
        // TODO
    }

    public(friend) fun client_address(self: &TransportControl): address {
        self.cli_addr
    }

    public(friend) fun server_address(self: &TransportControl): address {
        self.srv_addr
    }

    // Connection State Machine (work-in-progress):
    //
    //  Healthy transitions:
    //    created -------------- connection accepted -----> starting
    //    starting ------------ complete e2e encryption --> started
    //    started or recovered ---- payload transfer  ----> active
    //    any state ----- client request termination -----> terminating
    //
    //  Degradations:
    //    active    ----- no payload for 1 whole epoch -----> inactive
    //    any state -------- server requested hangup -------> server_hangup
    //    any state -------- client requested hangup -------> client_hangup
    //
    //  Recovery:
    //    inactive -------------- payload transfer ---------> active
    //    any hangup state -- connection retry accepted ----> recovering
    //    recovering ---------- renew e2e encryption -------> recovered
    //
    //  Deletion:
    //    terminating ----- server accept termination ------> <<OBJECT DELETED>>
    //    not active state -- persist for 30 whole epochs --> <<OBJECT DELETED>>
    //
    // Note: All epoch timeout may differ depending of the connection SLA.
    //
    // TODO State machine is for storage+fund management (to be done eventually)

}

#[test_only]
module dtp::test_transport_control {
    //use std::debug;
    //use std::option::{Self};

    //use sui::transfer;
    use sui::test_scenario::{Scenario};
    use sui::test_scenario as ts;
    //use sui::object;

    //use dtp::pipe::{Self};
    //use dtp::transport_control::{Self};  // DUT
    use dtp::host::{Self};

    fun create_hosts(scenario: &mut Scenario) {    
        ts::next_tx(scenario, @0x10);
        {
            let ctx = ts::ctx(scenario);
            let _client_host = host::new_transfered(ctx);
        };
        
        ts::next_tx(scenario, @0x20);
        {
            let ctx = ts::ctx(scenario);
            let _server_host = host::new_transfered(ctx);
        };
    }


    #[test]
    fun test_create() {
      let scenario_val = ts::begin(@0x10);
      let scenario = &mut scenario_val;
        
      create_hosts(scenario);
            
      ts::next_tx(scenario, @0x10);
      {
        // Client creates a connection.
        let _ctx = ts::ctx(scenario);
      };      

      ts::end(scenario_val);
    }

}
