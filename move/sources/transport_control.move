module dtp::transport_control {
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
    use sui::tx_context::{TxContext};

    //use sui::transfer;    
    //use dtp::pipe::{Self};

    // friend dtp::node;

    #[test_only]
    friend dtp::test_transport_control;

    // Control Plane of a connection.
    //
    // Shared object accessible only by the client and server
    // of a single connection.

    struct TransportControl has key {
        id: UID,

        // DTP Nodes.
        // Do not change for the lifetime of this object.
        // TODO Check if there is any const optimization possible here.
        client: Option<address>, // Not set on broadcast.
        server: address,

        // Connection Type.
        //
        // TODO Bi-directional, uni-directional or broadcast
        

        // Keep track of the related Pipes.
        //
        // Intended for slow discovery.
        //
        // It is expected that related DTP endpoints
        // will cache these IDs.
        // 
        // TODO Just one pipe per direction for now (Multi-Channel later)
        client_pipe: Option<ID>,
        server_pipe: Option<ID>,

        // Pipe Aggregated statistics (updated periodically)
        // Useful as a "feedback/debug" for the peer.
        // TODO
    }


    // Constructors
    // Public entry create not allowed.
    fun init(_ctx: &mut TxContext) {}

    public(friend) fun new( client: Option<address>, server: address, 
        client_pipe: Option<ID>, server_pipe: Option<ID>, ctx: &mut TxContext): TransportControl {
        TransportControl { id: object::new(ctx), client, server, client_pipe, server_pipe }
    }    

    public(friend) fun delete( self: TransportControl ) {
        let TransportControl { id, client, server: _, client_pipe, server_pipe } = self;

        // Extract the optional IDs.
        if (option::is_some(&client)) {
            option::destroy_some(client);
        } else {
            option::destroy_none(client);
        };

        if (option::is_some(&client_pipe)) {
            option::destroy_some(client_pipe);
        } else {
            option::destroy_none(client_pipe);
        };

        if (option::is_some(&server_pipe)) {
            option::destroy_some(server_pipe);
        } else {
            option::destroy_none(server_pipe);
        };

        object::delete(id);
    }    

    // Read accessors
    public fun server_address(self: &TransportControl): address {
        self.server
    }

    public fun client_address(self: &TransportControl): Option<address> {
        self.client
    }

}

#[test_only]
module dtp::test_transport_control {
    use std::debug;
    use std::option::{Self};

    use sui::transfer;
    use sui::test_scenario::{Self};
    use sui::object;

    use dtp::pipe::{Self, Pipe};
    use dtp::transport_control::{Self};  // DUT

    #[test]
    fun test_instantiation() {
        let node_creator = @0x1;
        let scenario_val = test_scenario::begin(node_creator);
        let scenario = &mut scenario_val;
        
        /* TODO Figure out how to call init, or is it always called by default?
        {
            transport_control::init(ctx);
        };*/

        let fake_client_address = @0x2;
        let fake_server_address = @0x3;
        let fake_client_pipe_id; // object::id_from_address(@0x0); // NULL
        let fake_server_pipe_id; // = object::id_from_address(@0x0); // NULL

        test_scenario::next_tx(scenario, node_creator);
        {
            let ctx = test_scenario::ctx(scenario);

            let fake_client_pipe = pipe::new(ctx);
            fake_client_pipe_id = object::id<Pipe>(&fake_client_pipe);

            let fake_server_pipe = pipe::new(ctx);
            fake_server_pipe_id = object::id<Pipe>(&fake_server_pipe);

            let tc = transport_control::new( option::some(fake_client_address),
                fake_server_address,
                option::some(fake_client_pipe_id),
                option::some(fake_server_pipe_id),
                ctx );

            // Test accessors
            assert!(transport_control::server_address(&tc) == fake_server_address, 1);

            debug::print(&tc);

            transfer::share_object( fake_client_pipe );
            transfer::share_object( fake_server_pipe );
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