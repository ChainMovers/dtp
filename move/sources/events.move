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
        src_addr: address, // InnerPipe address emitting the event.
        service_idx: u8, // Service Type [1..253]
        req_ipipe_idx: u8, // Uniquely identifies the originating request ipipe with an index [0..n_req_pipe-1]
        req_seq_num: u64, // Sequence number assigned by the originating ipipe.
        cli_host_ref: WeakRef, // Client Host Address (Optimization to minimize lookup at receiver).
        srv_host_ref: WeakRef, // Server Host Address (Optimization to minimize lookup at receiver).
        tc_ref: WeakRef, // TransportControl Address
        peer_ipipe_ref: WeakRef, // InnerPipe in the other direction.
        data: vector<u8>, // The endpoint response/request (e.g. JSON-RPC).
        cid: u64, // Correlation ID from the originating request endpoint.
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
  public(friend) fun emit_conn_req( src_addr: address, service_idx: u8, conn: ConnObjects ) {
    event::emit(ConnReq { flags: 0, src: 0x03, src_addr, service_idx, conn });
  }

  public(friend) fun emit_response( service_idx: u8, req_ipipe_idx: u8, req_seq_num: u64, cli_host_ref: WeakRef, srv_host_ref: WeakRef, tc_ref: WeakRef, ipipe_ref: WeakRef, peer_ipipe_ref: WeakRef, data: vector<u8>, cid: u64 ) {
    let src_addr = dtp::weak_ref::get_address(&ipipe_ref);    
    event::emit(Datagram { flags: 0, src: 0x02, src_addr, service_idx, req_ipipe_idx, req_seq_num, cli_host_ref, srv_host_ref, tc_ref, peer_ipipe_ref, data, cid });
  }

  public(friend) fun emit_request( service_idx: u8, req_ipipe_idx: u8, req_seq_num: u64, cli_host_ref: WeakRef, srv_host_ref: WeakRef, tc_ref: WeakRef, ipipe_ref: WeakRef, peer_ipipe_ref: WeakRef, data: vector<u8>, cid: u64 ) {
    let src_addr = dtp::weak_ref::get_address(&ipipe_ref);
    event::emit(Datagram { flags: 0, src: 0x01, src_addr, service_idx, req_ipipe_idx, req_seq_num, cli_host_ref, srv_host_ref, tc_ref, peer_ipipe_ref, data, cid });
  }

  // === Private Functions ===

  // === Test Functions ===    


}