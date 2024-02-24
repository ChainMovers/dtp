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
        service_idx: u8, // Service Type
        cli_haddr: address, // Client Host address (requester of the connection).
        srv_haddr: address, // Server Host address
        tc_addr: address, // Transport Control        

        // Address of the first inner pipe addresses to use.
        //
        // This is for faster initial response time
        // for some services (e.g. first ping).
        //
        // The server should find out about additional
        // inner pipes with a tc_addr object read.
        client_tx_ipipe: address,
        server_tx_ipipe: address,
    }


  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_con_req( service_idx: u8, cli_haddr: address, srv_haddr: address, tc_addr: address, client_tx_ipipe: address, server_tx_ipipe: address ) {
    event::emit(ConReq { service_idx, cli_haddr, srv_haddr, tc_addr, client_tx_ipipe, server_tx_ipipe});
  }

  // === Private Functions ===

  // === Test Functions ===    

  
}