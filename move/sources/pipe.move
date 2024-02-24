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

        tctl_id: WeakRef,
        inner_pipes: vector<WeakRef>,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new_transfered( tctl_id: &ID, inner_pipe_count: u8, recipient: address, ctx: &mut TxContext ): (WeakRef,WeakRef) {
        assert!(inner_pipe_count > 0, errors::EInvalidPipeCount());

        let new_pipe = Pipe {
            id: object::new(ctx),
            flgs: 0,            
            sync_data: pipe_sync_data::new(),
            tctl_id: weak_ref::new(tctl_id),
            inner_pipes: vector::empty(),
        };
        let pipe_address = uid_to_address(&new_pipe.id);

        // First InnerPipe created is "special" because the caller gets a WeakRef on it.
        let ipipe_ref = inner_pipe::new_transfered(&pipe_address, recipient, ctx);
        let ipipe_addr = weak_ref::get_address(&ipipe_ref);
        vector::push_back(&mut new_pipe.inner_pipes, ipipe_ref);

        // Create additional InnerPipes.
        inner_pipe_count = inner_pipe_count - 1;
        let i: u8 = 0;
        while (i < inner_pipe_count) {
            let ipipe_ref = inner_pipe::new_transfered(&pipe_address, recipient, ctx);
            vector::push_back(&mut new_pipe.inner_pipes, ipipe_ref);
        };

        transfer::transfer(new_pipe, recipient);

        (weak_ref::new_from_address(pipe_address), weak_ref::new_from_address(ipipe_addr))
    }

/* TODO
    public(friend) fun delete( self: Pipe, inner_pipes: vector<InnerPipe> ) {
        let Pipe { id, flgs: _, sync_data: _, tctl_id: _, inner_pipes } = self;        
        // Delete all the inner pipes.
        // For tracking/debugging purpose, the weak ref is not removed from vector (only cleared).
        let i: u64 = 0;
        while (i < vector::length(&inner_pipes)) {
            let inner_pipe_ref = vector::borrow_mut(&mut inner_pipes, i);
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
