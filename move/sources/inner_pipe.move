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
        ipipe_idx: u8,
        service_idx: u8,        
        cli_host_ref: WeakRef,
        srv_host_ref: WeakRef,
        tc_ref: WeakRef,
        pipe_ref: WeakRef,
        peer_pipe_ref: WeakRef,
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

    public(friend) fun new( ipipe_idx: u8, service_idx: u8, cli_id: &ID, srv_id: &ID, tc_id: &ID, pipe_addr: address, ctx: &mut TxContext ): InnerPipe {
        let new_obj = InnerPipe {
          id: object::new(ctx),
          flgs: 0u8,
          ipipe_idx,
          service_idx,
          cli_host_ref: weak_ref::new(cli_id),
          srv_host_ref: weak_ref::new(srv_id),
          tc_ref: weak_ref::new(tc_id),
          pipe_ref: weak_ref::new_from_address(pipe_addr),
          peer_pipe_ref: weak_ref::new_empty(),
          sync_data: pipe_sync_data::new(),          
          seq_num: 1,
          emit_cnt:0,
          sync_cnt: 0,
        };
        new_obj
    }

    public(friend) fun new_transfered( ipipe_idx: u8, service_idx: u8, cli_id: &ID, srv_id: &ID, tc_id: &ID, pipe_addr: address, recipient: address, ctx: &mut TxContext ): address
    {
      let new_obj = new( ipipe_idx, service_idx, cli_id, srv_id, tc_id, pipe_addr, ctx);
      let new_obj_addr = uid_to_address(&new_obj.id);
      transfer::transfer(new_obj, recipient);
      new_obj_addr
    }

    public(friend) fun delete( self: InnerPipe ) {
        let InnerPipe { id, flgs: _,
                        ipipe_idx: _, service_idx: _, 
                        cli_host_ref: _, srv_host_ref: _,
                        tc_ref: _, pipe_ref: _,
                        peer_pipe_ref: _,
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

    public(friend) fun get_cli_host_ref( self: &InnerPipe ): WeakRef {
      self.cli_host_ref
    }

    public(friend) fun get_srv_host_ref( self: &InnerPipe ): WeakRef {
      self.srv_host_ref
    }

    public(friend) fun get_tc_ref( self: &InnerPipe ): WeakRef {
      self.tc_ref
    }

    public(friend) fun get_peer_ref( self: &InnerPipe ): WeakRef {
      self.peer_pipe_ref
    } 

    public(friend) fun get_service_idx( self: &InnerPipe ): u8 {
      self.service_idx
    }

    public(friend) fun get_ipipe_idx( self: &InnerPipe ): u8 {
      self.ipipe_idx
    }

    public(friend) fun get_ipipe_address( self: &InnerPipe ): address {
      uid_to_address(&self.id)
    }

    public(friend) fun set_peer_ref( self: &mut InnerPipe, peer_pipe: &InnerPipe ) {
      weak_ref::set( &mut self.peer_pipe_ref, object::borrow_id<InnerPipe>(peer_pipe));
    }

    public(friend) fun transfer( self: InnerPipe, recipient: address ) {
        transfer::transfer(self, recipient);
    }

  
  // === Private Functions ===

  // === Test Functions ===  

}
