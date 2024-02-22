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
    //use dtp::errors::{Self};
    //use dtp::transport_control;
    use dtp::pipe_sync_data::{Self,PipeSyncData};

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

    struct InnerPipe has key, store {
        id: UID,
        flgs: u8, // DTP version+esc flags always after UID.

        pipe_id: WeakRef,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new_transfered( tctl_id: &ID, inner_pipe_count: u8, recipient: address, ctx: &mut TxContext ): WeakRef {
        let new_pipe = Pipe {
            id: object::new(ctx),
            flgs: 0,            
            sync_data: pipe_sync_data::new(),
            tctl_id: weak_ref::new(tctl_id),
            inner_pipes: vector::empty(),
        };
        let new_pipe_ref = weak_ref::new_from_address(uid_to_address(&new_pipe.id));
        let i: u8 = 0;
        while (i < inner_pipe_count) {
            let inner_pipe = InnerPipe {
                id: object::new(ctx),
                flgs: 0u8,
                pipe_id: new_pipe_ref,
            };
            let inner_pipe_ref = weak_ref::new_from_address(uid_to_address(&inner_pipe.id));
            vector::push_back(&mut new_pipe.inner_pipes, inner_pipe_ref);
            transfer::transfer(inner_pipe, recipient);
        };
        
        transfer::transfer(new_pipe, recipient);
        new_pipe_ref
    }

    public(friend) fun delete( self: Pipe ) {
        let Pipe { id, flgs: _, sync_data: _, tctl_id: _, inner_pipes: _ } = self;        
        object::delete(id);
    }

  // === Private Functions ===

  // === Test Functions ===  

}
