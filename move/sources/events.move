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
    struct ConnReq has copy, drop {
        service_idx: u8, // Service Type        
        conn: ConnObjects, // Info to get the connection started (e.g. Pipes and InnerPipes addresses).
    }


  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_conn_req( service_idx: u8, conn: ConnObjects ) {
    event::emit(ConnReq { service_idx, conn });
  }

  // === Private Functions ===

  // === Test Functions ===    

  
}