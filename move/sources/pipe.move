// A Pipes is a uni-directional data stream.
//   
// It is own by the endpoint transmiting data.
//
// Used only for simple transaction (no consensus).
// 
#[allow(unused_field, unused_use)]
module dtp::pipe {

  // === Imports ===
    use std::vector;  
    use sui::object::{Self, UID, ID, uid_to_address};
    use sui::transfer::{Self};
    use sui::tx_context::{TxContext};
    use dtp::weak_ref::{Self,WeakRef};
    use dtp::errors::{Self};    
    use dtp::pipe_sync_data::{Self,PipeSyncData};
    use dtp::inner_pipe::{Self};

    use dtp::conn_objects::{Self,ConnObjects};

  // === Friends ===
    friend dtp::host;
    friend dtp::transport_control;

    #[test_only]
    friend dtp::tests_pipe;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    struct Pipe has key {
        id: UID,
        flgs: u8, // DTP version+esc flags always after UID.
        service_idx: u8,
        cli_host_ref: WeakRef,
        srv_host_ref: WeakRef,
        tc_ref: WeakRef, // TransportControl
        ipipe_refs: vector<WeakRef>, // InnerPipe(s)
        sync_data: PipeSyncData, // Merged of all InnerPipe sync_data.
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    // Create two pipes at once
    public(friend) fun new_pipes( service_idx: u8, cli_id: &ID, srv_id: &ID, tc_id: &ID, ipipe_count: u8, cli_recipient: address, srv_recipient: address, conn: &mut ConnObjects, ctx: &mut TxContext ): (Pipe,Pipe) {
        assert!(ipipe_count > 0, errors::EInvalidPipeCount());

        let cli_pipe = Pipe {
            id: object::new(ctx),
            flgs: 0,
            service_idx,
            cli_host_ref: weak_ref::new(cli_id),
            srv_host_ref: weak_ref::new(srv_id),
            tc_ref: weak_ref::new(tc_id),
            ipipe_refs: vector::empty(),
            sync_data: pipe_sync_data::new(),
        };

        let srv_pipe = Pipe {
            id: object::new(ctx),
            flgs: 0,
            service_idx,
            cli_host_ref: weak_ref::new(cli_id),
            srv_host_ref: weak_ref::new(srv_id),
            tc_ref: weak_ref::new(tc_id),
            ipipe_refs: vector::empty(),
            sync_data: pipe_sync_data::new(),
        };

        let cli_pipe_addr = uid_to_address(&cli_pipe.id);
        conn_objects::set_cli_tx_pipe(conn, cli_pipe_addr);

        let srv_pipe_addr = uid_to_address(&srv_pipe.id);
        conn_objects::set_srv_tx_pipe(conn, srv_pipe_addr);

        // Create InnerPipes.
        let ipipe_idx: u8 = 0;
        while (ipipe_idx < ipipe_count) {
            let cli_ipipe= inner_pipe::new(ipipe_idx, service_idx, cli_id, srv_id, tc_id, cli_pipe_addr, ctx);
            let srv_ipipe= inner_pipe::new(ipipe_idx, service_idx, cli_id, srv_id, tc_id, srv_pipe_addr, ctx);

            // Cross-reference the inner pipes.
            inner_pipe::set_peer_ref(&mut cli_ipipe, &srv_ipipe);
            inner_pipe::set_peer_ref(&mut srv_ipipe, &cli_ipipe);

            // Save WeakRef in the Pipe object (for slow discovery), and the addresses in 
            // the ConnObjects (to be return/emitted to the end-points).
            let cli_ipipe_addr = inner_pipe::get_ipipe_address(&cli_ipipe);
            let srv_ipipe_addr = inner_pipe::get_ipipe_address(&srv_ipipe);

            conn_objects::add_cli_tx_ipipe(conn, cli_ipipe_addr);            
            conn_objects::add_srv_tx_ipipe(conn, srv_ipipe_addr);
                        
            let cli_ipipe_ref = weak_ref::new_from_address(cli_ipipe_addr);
            let srv_ipipe_ref = weak_ref::new_from_address(srv_ipipe_addr);
            vector::push_back(&mut cli_pipe.ipipe_refs, cli_ipipe_ref);
            vector::push_back(&mut srv_pipe.ipipe_refs, srv_ipipe_ref);
            inner_pipe::transfer(cli_ipipe, cli_recipient);
            inner_pipe::transfer(srv_ipipe, srv_recipient);
            ipipe_idx = ipipe_idx + 1;            
        };

        (cli_pipe, srv_pipe)
    }

    public(friend) fun transfer( self: Pipe, recipient: address ) {
        transfer::transfer(self, recipient);
    }
}