// All events emitted by DTP.

module dtp::events {
  // === Imports ===
    use sui::event;
    use dtp::conn_objects::ConnObjects;
    use dtp::weak_ref::WeakRef;

  // === Friends ===
    friend dtp::host;  
    friend dtp::inner_pipe;
    friend dtp::transport_control;    
    friend dtp::api_impl;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    // TODO Add KValues to all events for future proofing.
    struct ConnReq has copy, drop {
        flags: u8, // Reserve for future.        
        src: u8, // Typically 0x03 because coming from Host.
        src_addr: address,  // Host Address
        service_idx: u8, // Service Type [1..253]        
        conn: ConnObjects, // Enough info to get the connection started (e.g. TC, Pipes and InnerPipes addresses).
    }

    struct Datagram has copy, drop {
        flags: u8, // Reserve for future.
        src: u8, // 0x01 or 0x02 for respectively cli_tx_ipipe and srv_tx_ipipe.
        src_addr: address, // InnerPipe Address
        service_idx: u8, // Service Type [1..253]
        seq_num: u64,
        tc_ref: WeakRef, // TransportControl Address.
        data: vector<u8>, // The endpoint response/request (e.g. JSON-RPC).
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_conn_req( src_addr: address, service_idx: u8, conn: ConnObjects ) {
    event::emit(ConnReq { flags: 0, src: 0x03, src_addr, service_idx, conn });
  }

  public(friend) fun emit_response( service_idx: u8, seq_num: u64, tc_ref: WeakRef, ipipe_ref: WeakRef, data: vector<u8> ) {
    let src_addr = dtp::weak_ref::get_address(&ipipe_ref);    
    event::emit(Datagram { flags: 0, src: 0x02, src_addr, service_idx, seq_num, tc_ref, data });
  }

  public(friend) fun emit_request( service_idx: u8, seq_num: u64, tc_ref: WeakRef, ipipe_ref: WeakRef, data: vector<u8> ) {
    let src_addr = dtp::weak_ref::get_address(&ipipe_ref);
    event::emit(Datagram { flags: 0, src: 0x01, src_addr, service_idx, seq_num, tc_ref, data });
  }

  // === Private Functions ===

  // === Test Functions ===    

 
}