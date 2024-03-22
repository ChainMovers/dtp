// A Pipes is a uni-directional data stream.
//   
// It is own by the endpoint transmiting data.
//
// Used only for simple transaction (no consensus).
// 
#[allow(unused_field, unused_use)]
module dtp::inner_pipe {

  // === Imports ===    
    use sui::object::{Self, UID, ID, uid_to_address};
    use sui::transfer::{Self};
    use sui::tx_context::{TxContext};
    use dtp::weak_ref::{Self,WeakRef};
    //use dtp::errors::{Self};
    use dtp::pipe_sync_data::{Self,PipeSyncData};

  // === Friends ===
    friend dtp::host;
    friend dtp::pipe;
    friend dtp::api_impl;

    #[test_only]
    friend dtp::tests_pipe;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    struct InnerPipe has key, store {
        id: UID,
        flgs: u8, // DTP version+esc flags always after UID.
        service_idx: u8,
        tc_ref: WeakRef,
        pipe_ref: WeakRef,
        sync_data: PipeSyncData,
        seq_num: u64,
        // Stats to help debugging.
        emit_cnt: u64,
        sync_cnt: u64,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new( service_idx: u8, tc_id: &ID, pipe_addr: address, ctx: &mut TxContext ): InnerPipe {
        let new_obj = InnerPipe {
          id: object::new(ctx),
          flgs: 0u8,
          service_idx,
          tc_ref: weak_ref::new(tc_id),
          pipe_ref: weak_ref::new_from_address(pipe_addr),
          sync_data: pipe_sync_data::new(),          
          seq_num: 1,
          emit_cnt:0,
          sync_cnt: 0,
        };
        new_obj
    }

    public(friend) fun new_transfered( service_idx: u8, tc_id: &ID, pipe_addr: address, recipient: address, ctx: &mut TxContext ): address
    {
      let new_obj = new(service_idx, tc_id, pipe_addr, ctx);
      let new_obj_addr = uid_to_address(&new_obj.id);
      transfer::transfer(new_obj, recipient);
      new_obj_addr
    }

    public(friend) fun delete( self: InnerPipe ) {
        let InnerPipe { id, flgs: _, service_idx: _, 
                        tc_ref: _, pipe_ref: _,
                        sync_data: _, 
                        seq_num: _ ,
                        emit_cnt: _, sync_cnt: _
                      } = self;

        object::delete(id);
    }

    public(friend) fun inc_seq_num( self: &mut InnerPipe ): u64 {
      self.seq_num = self.seq_num  + 1;
      self.seq_num
    }

    public(friend) fun inc_emit_cnt( self: &mut InnerPipe ): u64 {
      self.emit_cnt = self.emit_cnt  + 1;
      self.emit_cnt
    }

    public(friend) fun inc_sync_cnt( self: &mut InnerPipe ): u64 {
      self.sync_cnt = self.sync_cnt  + 1;
      self.sync_cnt
    }

    public(friend) fun get_address( self: &InnerPipe ): address {
      weak_ref::get_address(&self.tc_ref )
    }

    public (friend) fun get_tc_ref( self: &InnerPipe ): WeakRef {
      self.tc_ref
    }

    public (friend) fun get_service_idx( self: &InnerPipe ): u8 {
      self.service_idx
    }

  // === Private Functions ===

  // === Test Functions ===  

}
