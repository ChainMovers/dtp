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

        sync_data: PipeSyncData, // Merged of all InnerPipe sync_data.

        tc: WeakRef, // TransportControl
        ipipes: vector<WeakRef>, // InnerPipe(s)
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new_transfered( tc: &ID, ipipe_count: u8, recipient: address, is_cli_tx_pipe: bool, conn: &mut ConnObjects, ctx: &mut TxContext ): WeakRef {
        assert!(ipipe_count > 0, errors::EInvalidPipeCount());

        let new_pipe = Pipe {
            id: object::new(ctx),
            flgs: 0,            
            sync_data: pipe_sync_data::new(),
            tc: weak_ref::new(tc),
            ipipes: vector::empty(),
        };

        let pipe_addr = uid_to_address(&new_pipe.id);
        if (is_cli_tx_pipe) {
          conn_objects::set_cli_tx_pipe(conn, pipe_addr);
        } else {
          conn_objects::set_srv_tx_pipe(conn, pipe_addr);
        };
    
        // Create InnerPipes.
        let i: u8 = 0;
        while (i < ipipe_count) {
            let ipipe_ref = inner_pipe::new_transfered(&pipe_addr, recipient, ctx);
            let ipipe_addr = weak_ref::get_address(&ipipe_ref);

            // Save WeakRef in the Pipe object (for slow discovery), and the addresses in 
            // the ConnObjects (to be return/emitted to the end-points).
            vector::push_back(&mut new_pipe.ipipes, ipipe_ref);
            if (is_cli_tx_pipe) {
                conn_objects::add_cli_tx_ipipe(conn, ipipe_addr);
            } else {
                conn_objects::add_srv_tx_ipipe(conn, ipipe_addr);
            };
        };

        transfer::transfer(new_pipe, recipient);

        weak_ref::new_from_address(pipe_addr)
    }

/* TODO
    public(friend) fun delete( self: Pipe, ipipes: vector<InnerPipe> ) {
        let Pipe { id, flgs: _, sync_data: _, tc: _, ipipes } = self;        
        // Delete all the inner pipes.
        // For tracking/debugging purpose, the weak ref is not removed from vector (only cleared).
        let i: u64 = 0;
        while (i < vector::length(&ipipes)) {
            let inner_pipe_ref = vector::borrow_mut(&mut ipipes, i);
            let inner_pipe_id = weak_ref::id(inner_pipe_ref);
            weak_ref::clear(inner_pipe_ref);
            object::delete(inner_pipe_id);
            inner_pipe::delete(inner_pipe_id);
            i = i + 1;
        };
        object::delete(id);
    }
*/

  // === Private Functions ===

  // === Test Functions ===  

}
