// All events emitted by DTP.

module dtp::events {
  // === Imports ===
    use sui::event;
  // === Friends ===
    friend dtp::host;  
    friend dtp::inner_pipe;
    friend dtp::transport_control;

  // === Errors ===

  // === Constants ===

  // === Structs ===
    struct ConReq has copy, drop {
        // TODO Add ServiceTYpe, Pipe and InnerPipe addresses.
        tc_address: address, // Transport Control Address.
        sender: address, // Sender requesting the connection.
    }


  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_con_req( tc_address: address, sender: address ) {
    event::emit(ConReq {tc_address, sender} );
  }

  // === Private Functions ===

  // === Test Functions ===    

  
}