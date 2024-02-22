// PipeSyncData object
//
// Data that flows from InnerPipe -> Pipe -> TransportControl -> Host
// The data is aggregated as it flows toward Host.
//
#[test_only]
module dtp::tests_pipe {

  // === Imports ===
    use sui::test_utils::assert_eq;
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
      let ctx = ts::ctx(scn);
      //let sender = tx_context::sender(ctx);

      //let psd = dtp::pipe::new(ctx);
    };

    ts::end(scn_obj);
  }

}            
