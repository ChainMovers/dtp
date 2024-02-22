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

    use std::option::{Self, Option};

    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self,TxContext};
    use sui::event;
    use sui::transfer;

    use dtp::service_type::{Self};
    use dtp::errors::{Self};
    use dtp::weak_ref::{Self,WeakRef};
    use dtp::host::{Self,Host};

    #[test_only]
    friend dtp::test_transport_control;

    struct BEConReq has copy, drop {
        sender: address, // Sender Requesting a Connection
    }

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
        client_host: WeakRef,
        server_host: WeakRef,
        
        // Authorization verified by sender ID address.        
        client_addr: address,
        server_addr: address,

        // Connection Type.
        //
        // TODO Bi-directional, uni-directional or broadcast. Always bi-directional for now.

        // Keep track of the related Pipes.
        //
        // Intended for slow discovery.
        //
        // It is expected that DTP off-chain will cache these IDs.
        //
        // Optional in case of uni-directiobal connection.
        client_tx_pipe: WeakRef,
        server_tx_pipe: WeakRef,
    }


    // Constructors

    public(friend) fun new( service_idx: u8,
        client_host: &mut Host,
        server_host: &mut Host,
        ctx: &mut TxContext): TransportControl
    {
        // Check service_idx is in-range.        
        assert!(service_idx < service_type::SERVICE_TYPE_MAX_IDX(), errors::EServiceIdxOutOfRange());
        
        // If address are same, then the host ID must be the same, else the host ID must be different.
        /*
        if (client_addr == server_addr) {
            assert!(client_host == server_host, errors::EHostAddressMismatch1());
        } else {
            assert!(client_host != server_host, errors::EHostAddressMismatch2());
        };*/

        // Verify that at least one pipe is provided._
        /*
        let is_client_tx_pipe_set = weak_ref::is_set(&client_tx_pipe);
        let is_server_tx_pipe_set = weak_ref::is_set(&server_tx_pipe);
        assert!(is_client_tx_pipe_set || is_server_tx_pipe_set, errors::EOnePipeRequired());
        */

        // If two pipes are provided, they must be different objects.
        /*
        if (is_client_tx_pipe_set && is_server_tx_pipe_set) {
            let pipe1 = weak_ref::get_address(&client_tx_pipe);
            let pipe2 = weak_ref::get_address(&server_tx_pipe);
            assert!(pipe1 != pipe2, errors::EPipeInstanceSame());
        };*/

        let tc = TransportControl {
            id: object::new(ctx), 
            flags: 0,
            service_idx,
            client_host: weak_ref::new_from_obj(client_host),
            server_host: weak_ref::new_from_obj(server_host),
            client_addr: host::owner(client_host),
            server_addr: host::owner(server_host),
            client_tx_pipe: weak_ref::new_empty(),
            server_tx_pipe: weak_ref::new_empty(),
        };

        // Weak references between Pipes and TC (for recovery scenario).        
        tc.client_tx_pipe = dtp::pipe::new_transfered(object::borrow_id<TransportControl>(&tc), 2, tc.client_addr, ctx);
        tc.server_tx_pipe = dtp::pipe::new_transfered(object::borrow_id<TransportControl>(&tc), 2, tc.server_addr, ctx);

        tc
    }


    public(friend) fun delete( self: TransportControl ) {
        let TransportControl { id, flags: _,
          service_idx: _,
          client_host: _, server_host: _,
          client_addr: _, server_addr: _,
          client_tx_pipe: _, server_tx_pipe: _,
        } = self;

        object::delete(id);
    }    

    // Read accessors
    public(friend) fun server_addr(self: &TransportControl): address {
        self.server_addr
    }

    public(friend) fun client_addr(self: &TransportControl): address {
        self.client_addr
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
    // Best-effort has very little control and could be decline in case of a server
    // being too busy. At worst, the server is not going to respond to the connection 
    // request and the client will have wasted gas attempting to connect.
    //
    // Pre-approved Service is a more controlled approach where the connection is
    // "guaranteed" to work for the approved user. It is more appropriate in
    // circumstance where there is an off-chain business relationship.
    //
    #[allow(lint(share_owned))]
    public entry fun create_best_effort( service_idx: u8,
                                         client_host: &mut Host,
                                         server_host: &mut Host,                                         
                                         ctx: &mut TxContext )    
    {
        // Sender must be the owner of the client_host.    
        assert!(host::is_caller_owner(client_host, ctx), errors::EHostNotOwner());

        // Create the TransportControl/Pipes/InnerPipes
        //
        // A "Connection Request" event is emited. The server may choose to 
        // accept the connection, ignore the request or pro-actively
        // refuse the request (which is relatively nice since it save the 
        // client some storage fee by allowing to delete the object created).
        //
        let tc = dtp::transport_control::new(service_idx, client_host, server_host, ctx);

        // Emit the "Connection Request" Move event.
        // The server will see the sender object therefore will know the TC and plenty of info!
        event::emit(BEConReq { 
                sender: client_address(&tc), // Allows further off-chain filtering/firewall.
            } );
        transfer::share_object(tc);
    }

    public entry fun create_preapproved( _ctx: &mut TxContext ) 
    {
        // TODO
    }

    public(friend) fun client_address(self: &TransportControl): address {
        self.client_addr
    }

    public(friend) fun server_address(self: &TransportControl): address {
        self.server_addr
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
    use std::option::{Self};

    use sui::transfer;
    use sui::test_scenario::{Self};
    use sui::object;

    use dtp::pipe::{Self};
    use dtp::transport_control::{Self};  // DUT
    use dtp::host::{Self, Host};

    #[test]
    fun test_instantiation() {
        let creator = @0x1;
        let scenario_val = test_scenario::begin(creator);
        let scenario = &mut scenario_val;
        
        let fake_client_address = @0x20;
        let fake_server_address = @0x30;
        let fake_client_pipe_id;
        let fake_server_pipe_id;

        test_scenario::next_tx(scenario, creator);
        {
            let ctx = test_scenario::ctx(scenario);

            fake_client_pipe_id = pipe::create_internal(ctx, fake_client_address);
            fake_server_pipe_id = pipe::create_internal(ctx, fake_client_address);

            let fake_client_host = host::new(ctx);
            let fake_client_host_id = object::id<Host>(&fake_client_host);

            let fake_server_host = host::new(ctx);
            let fake_server_host_id = object::id<Host>(&fake_server_host);

            let port : u16 = 0 ;
            let protocol : u16 = 0;
            let return_port : u16 = 0;
            let tc = transport_control::new( 
                option::some(fake_client_host_id), fake_server_host_id,
                option::some(fake_client_address), fake_server_address,
                option::some(fake_client_pipe_id), option::some(fake_server_pipe_id),
                protocol, option::some(port), option::some(return_port),
                ctx );

            // Test accessors
            assert!(transport_control::server_addr(&tc) == fake_server_address, 1);

            //debug::print(&tc);

            transfer::share_object( fake_client_host );
            transfer::share_object( fake_server_host );
            transfer::share_object( tc );
        };

        // Destruction 
        // TODO Revisit this once shared object deletion works!?
        /*
        test_scenario::next_tx(scenario, node_creator);
        {
            let tc = test_scenario::take_shared<TransportControl>(scenario);
            let fake_client_pipe = test_scenario::take_shared_by_id<Pipe>(scenario,fake_client_pipe_id);
            let fake_server_pipe = test_scenario::take_shared_by_id<Pipe>(scenario,fake_server_pipe_id);

            transport_control::delete(tc);
            pipe::delete(fake_client_pipe);
            pipe::delete(fake_server_pipe);
        };*/

        test_scenario::end(scenario_val);
    }

}
