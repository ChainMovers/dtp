// A Pipes is a uni-directional data stream.
//   
// It is own by the endpoint transmiting data.
//
// Used only for simple transaction (no consensus).
// 
#[allow(unused_field, unused_use)]
module dtp::inner_pipe {

  // === Imports ===    
    use sui::object::{Self, UID, uid_to_address};
    use sui::transfer::{Self};
    use sui::tx_context::{TxContext};
    use dtp::weak_ref::{Self,WeakRef};
    //use dtp::errors::{Self};
    use dtp::pipe_sync_data::{Self,PipeSyncData};

  // === Friends ===
    friend dtp::host;
    friend dtp::pipe;

    #[test_only]
    friend dtp::tests_pipe;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    struct InnerPipe has key, store {
        id: UID,
        flgs: u8, // DTP version+esc flags always after UID.

        pipe_id: WeakRef,

        sync_data: PipeSyncData,
    }

  // === Public-Mutative Functions ===
    public entry fun send(
        _self: &mut InnerPipe,
        _data: vector<u8>,
        _ctx: &mut TxContext )
    {
      // TODO Emit the event. Add sequential number logic.
    }

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new( pipe_address: address, ctx: &mut TxContext  ): InnerPipe {
        let new_obj = InnerPipe {
          id: object::new(ctx),
          flgs: 0u8,
          pipe_id: weak_ref::new_from_address(pipe_address),
          sync_data: pipe_sync_data::new(),
        };
        new_obj
    }

    public(friend) fun new_transfered( pipe_address: address, recipient: address, ctx: &mut TxContext  ): WeakRef 
    {
      let new_obj = new(pipe_address,ctx);
      let new_obj_ref = weak_ref::new_from_address(uid_to_address(&new_obj.id));
      transfer::transfer(new_obj, recipient);
      new_obj_ref      
    }

    public(friend) fun delete( self: InnerPipe ) {
        let InnerPipe { id, flgs: _, pipe_id: _, sync_data: _ } = self;
        object::delete(id);
    }

  // === Private Functions ===

  // === Test Functions ===  

}
