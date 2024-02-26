// All events emitted by DTP.

module dtp::events {
  // === Imports ===
    use sui::event;
    use dtp::conn_objects::ConnObjects;

  // === Friends ===
    friend dtp::host;  
    friend dtp::inner_pipe;
    friend dtp::transport_control;

  // === Errors ===

  // === Constants ===

  // === Structs ===
    struct ConReq has copy, drop {
        service_idx: u8, // Service Type
        conn: ConnObjects, // All Connection Objects (TransportControl, Pipe etc...)       
    }


  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_conn_req( service_idx: u8, conn: ConnObjects ) {
    event::emit(ConReq { service_idx, conn });
  }

  // === Private Functions ===

  // === Test Functions ===    

  
}