// PipeSyncData object
//
// Data that flows from InnerPipe -> Pipe -> TransportControl -> Host
// The data is aggregated as it flows toward Host.
//
#[test_only]
module dtp::tests_pipe_sync_data {

  // === Imports ===
    //use sui::test_utils::assert_eq;
    use sui::test_scenario::{Self as ts};

  // === Errors ===

  // === Constants ===

  // === Structs ===

  // === Private Functions ===

  // === Test Functions ===  
  #[test]
  fun test_new() {
    let user = @0x10;
    let scn_obj = ts::begin(@0x1);
    let scn = &mut scn_obj;

    ts::next_tx(scn, user);
    { 
      let _ctx = ts::ctx(scn);
      //let sender = tx_context::sender(ctx);

      let _psd = dtp::pipe_sync_data::new();
      //assert_eq(psd.byte_payload_sent, 0);
      //assert_eq(psd.byte_header_sent, 0);
      //assert_eq(psd.send_call_completed, 0);      
    };

    ts::end(scn_obj);
  }

}            
