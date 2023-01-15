module dtp::transport_control {

    struct BEConReq has copy, drop {
        sender: address, // Sender Requesting a Connection
    }

    // Code order guideline? (WIP - still learning):
    //    use (std, sui, other, dtp)
    //    { friend }
    //    ============ Public structs ================
    //    public struct+accessors
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

    //use sui::transfer;    
    //use dtp::pipe::{Self};

    // friend dtp::node;

    #[test_only]
    friend dtp::test_transport_control;

    // Control Plane of a connection.
    //
    // Shared object with public entry functions allowed only 
    // for the client and server of the related connection.
    struct TransportControl has key {
        id: UID,

        client_host: Option<ID>, // Not set on broadcast.
        server_host: ID,

        // Do not change for the lifetime of this object.
        client_authority: Option<address>, // Not set on broadcast.
        server_admin: address,


        // Connection Type.
        //
        // TODO Bi-directional, uni-directional or broadcast. Always bi-directional for now.
        

        // Keep track of the related Pipes.
        //
        // Intended for slow discovery.
        //
        // It is expected that related DTP endpoints
        // will cache these IDs.
        // 
        // TODO Just one pipe per direction for now (Multi-Channel later)
        client_tx_pipe: Option<ID>,
        server_tx_pipe: Option<ID>,

        // {Protocol,Port} tupple aka the Service.
        protocol: u16,
        port: Option<u16>,

        // Intended for traffic returning to the client in a bi-directional connection.        
        return_port: Option<u16>,

        // Pipe Aggregated statistics (updated periodically)
        // Useful as a "feedback/debug" for the peer.
        // TODO
    }


    // Constructors

    fun init(_ctx: &mut TxContext) {}

    public(friend) fun new(
        client_host: Option<ID>, server_host: ID,
        client_authority: Option<address>, server_admin: address,
        client_tx_pipe: Option<ID>, server_tx_pipe: Option<ID>,
        protocol: u16, port: Option<u16>, return_port: Option<u16>,
        ctx: &mut TxContext): TransportControl
    {
        TransportControl {
            id: object::new(ctx),
            client_host, server_host,
            client_authority, server_admin,
            client_tx_pipe, server_tx_pipe,
            protocol, port, return_port
        }
    }


    public(friend) fun delete( self: TransportControl ) {
        let TransportControl { id,
          client_host, server_host: _,
          client_authority, server_admin: _,
          client_tx_pipe, server_tx_pipe,
          protocol: _, port: _, return_port: _
        } = self;
        if (option::is_some(&client_host)) {
            option::destroy_some(client_host);
        } else {
            option::destroy_none(client_host);
        };

        if (option::is_some(&client_authority)) {
            option::destroy_some(client_authority);
        } else {
            option::destroy_none(client_authority);
        };

        if (option::is_some(&client_tx_pipe)) {
            option::destroy_some(client_tx_pipe);
        } else {
            option::destroy_none(client_tx_pipe);
        };

        if (option::is_some(&server_tx_pipe)) {
            option::destroy_some(server_tx_pipe);
        } else {
            option::destroy_none(server_tx_pipe);
        };

        object::delete(id);
    }    

    // Read accessors
    public(friend) fun server_admin(self: &TransportControl): address {
        self.server_admin
    }

    public(friend) fun client_authority(self: &TransportControl): Option<address> {
        self.client_authority
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
    // may ultimately depend on following the proper procedure in the first place.
    //
    // A pre-approval is not a guarantee of service (the server might go down between
    // the pre-approval and using it), but DTP decentralized logic attempts to keep
    // the expectation realistic (base on recent server stats) that the service will be
    // available.
    //
    // Best-effort has very little control and could overwhelm the server. At worst, the
    // server is not going to respond to the connection request and the client will have
    // wasted gas attempting to connect.
    //
    // Pre-approved Service is a more controlled approach where the connection is
    // very likely to work for the approved user. It is more appropriate in any
    // circumstance where a service level agreement is expected (e.g. customer 
    // and business relationship). Firewall and controlled access is possible,
    // the server ressources is reserved for their intended users.
    //
    public entry fun create_best_effort( client_host: Option<ID>, server_host: ID,
                                         server_admin: address,
                                         protocol: u16,
                                         port: Option<u16>,
                                         return_port: Option<u16>,
                                         ctx: &mut TxContext )    
    {
        // Create the tx pipes and the TransportControl itself.
        //
        // A "Connection Request" event is emited. The server may choose to 
        // accept the connection, ignore the request or pro-actively
        // refuse the request (which is relatively nice since it save the 
        // client some storage fee by allowing to delete the object created).
        //         
        let tc = dtp::transport_control::new(
            client_host, server_host,
            option::some(tx_context::sender(ctx)), server_admin, // client_authority, server_admin             
            option::none(), option::none(),
            protocol, port, return_port, ctx );

        let sender = tx_context::sender(ctx);
        // Weak references between Pipes and TC using ID (for recovery scenario).
        tc.client_tx_pipe = option::some(dtp::pipe::create_internal(ctx, sender));
        tc.server_tx_pipe = option::some(dtp::pipe::create_internal(ctx, server_admin));

        // Emit the "Connection Request" Move event.
        // The server will see the sender object therefore will know the TC and plenty of info!
        event::emit(BEConReq { 
                sender: tx_context::sender(ctx), // Allows to filter out early spammers.
            } );
        transfer::share_object(tc);
    }

    public entry fun create_preapproved( _ctx: &mut TxContext ) 
    {
        // TODO
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
        
        /* TODO Figure out how to call init, or is it always called by default?
        {
            transport_control::init(ctx);
        };*/

        let fake_client_address = @0x2;
        let fake_server_address = @0x3;
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
            assert!(transport_control::server_admin(&tc) == fake_server_address, 1);

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
