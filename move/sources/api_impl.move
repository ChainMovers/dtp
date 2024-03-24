module dtp::api_impl {

  // === Imports ===
    use sui::tx_context::{TxContext};

    use dtp::host::{Self,Host};
    use dtp::transport_control::{Self};
    use dtp::conn_objects::{Self};
    use dtp::transport_control::{TransportControl};
    use dtp::pipe::{Pipe};
    use dtp::inner_pipe::{Self,InnerPipe};
    use dtp::kvalues::{Self,KValues};
    use dtp::events::{Self};

    use dtp::weak_ref::{Self};

  // === Friends ===
    friend dtp::api;

  // === Errors ===

  // === Constants ===

  // === Structs ===

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  // Functions to add services to an Host.
  public(friend) fun create_host(_kvargs: &KValues, ctx: &mut TxContext) : (address, KValues)
  {
    let host_ref = host::new_transfered(ctx);
    (weak_ref::get_address(&host_ref), kvalues::new())
  }

  // Functions to add services to an Host.
  public(friend) fun add_service_ping(_host: &mut Host, _kvargs: &KValues, _ctx: &mut TxContext) : KValues
  {
    kvalues::new()
  }

  // JSON-RPC 2.0 service
  public(friend) fun add_service_json_rpc(_host: &mut Host, _kvargs: &KValues, _ctx: &mut TxContext) : KValues
  {
    kvalues::new()
  }
  

  // Returns IDs of objects needed to start exchanging data (TransportControl, Pipes, InnerPipes...).  
  public(friend) fun open_connection(service_idx: u8, cli_host: &mut Host, srv_host: &mut Host, _kvargs: &KValues, ctx: &mut TxContext): KValues
  {
    let conn = conn_objects::new();

    // Create the connection. Will emit an event on success
    transport_control::create_best_effort(service_idx, cli_host, srv_host, &mut conn, ctx);

    // Add weak references in Host objects for slow discovery.
    host::add_connection(cli_host, weak_ref::new_from_address(conn_objects::get_tc_address(&conn)));
    host::add_connection(srv_host, weak_ref::new_from_address(conn_objects::get_tc_address(&conn)));

    kvalues::new()
  }

  // Can this be replaced with a an array of _ipipe objects instead of calling multiple times?
  public(friend) fun close_ipipe(ipipe: InnerPipe, _pipe: &mut Pipe, _kvargs: &KValues, _ctx: &mut TxContext ) : KValues {
    inner_pipe::delete(ipipe);
    kvalues::new()
  }

  public(friend) fun close_pipe(_pipe: &mut Pipe, _tc: &mut TransportControl, _kvargs: &KValues, _ctx: &mut TxContext) : KValues {
    kvalues::new()
  }

  public(friend) fun close_connection(_service_idx: u8, _host: &mut Host, _peer_host: &Host, _tc: &mut TransportControl, _kvargs: &KValues, _ctx: &mut TxContext): KValues
  {
    kvalues::new()
  }

  // Any end-point must perform the following two steps from time to time:
  //  1) Call sync_ipipe() for every owned ipipe.
  //  2) Call sync_pipe() for the owned pipe.
  public(friend) fun fast_sync_ipipe(_ipipe: &mut InnerPipe, _pipe: &mut Pipe, _kvargs: &KValues, _ctx: &mut TxContext) : KValues
  {
    kvalues::new()
  }

  public(friend) fun slow_sync_pipe(_pipe: &mut Pipe, _tc: &mut TransportControl, _kvargs: &KValues, _ctx: &mut TxContext) : KValues
  {
    kvalues::new()
  }

  // Transmit a request toward the server.
  //
  // The encoding of the 'data' depends on the service.
  public(friend) fun send_request(ipipe: &mut InnerPipe, data: vector<u8>, cid: u64, _kvargs: &KValues, _ctx: &mut TxContext): KValues
  {    
    let req_seq_num = inner_pipe::inc_seq_num(ipipe);
    let req_ipipe_idx = inner_pipe::get_ipipe_idx(ipipe);

    // Emit a request event.
    let cli_host_ref = inner_pipe::get_cli_host_ref(ipipe);
    let srv_host_ref = inner_pipe::get_srv_host_ref(ipipe);
    let ipipe_ref = weak_ref::new_from_obj(ipipe);
    let peer_ipipe_ref = inner_pipe::get_peer_ref(ipipe);    
    let tc_ref = inner_pipe::get_tc_ref(ipipe);
    let service_idx = inner_pipe::get_service_idx(ipipe);  
    
    events::emit_request(service_idx, req_ipipe_idx, req_seq_num, cli_host_ref, srv_host_ref, tc_ref, ipipe_ref, peer_ipipe_ref, data, cid );

    // Update stats for debugging.
    inner_pipe::inc_emit_cnt(ipipe);

    kvalues::new()
  }

  // Transmit a response toward the client.
  //
  // The encoding of the 'data' depends on the service.
  public(friend) fun send_response(ipipe: &mut InnerPipe, req_ipipe_idx: u8, req_seq_num: u64, data: vector<u8>, cid: u64, _kvargs: &KValues, _ctx: &mut TxContext): KValues
  {
    // Emit a response event.   
    let cli_host_ref = inner_pipe::get_cli_host_ref(ipipe);
    let srv_host_ref = inner_pipe::get_srv_host_ref(ipipe);
    let ipipe_ref = weak_ref::new_from_obj(ipipe);    
    let peer_ipipe_ref = inner_pipe::get_peer_ref(ipipe);
    let tc_ref = inner_pipe::get_tc_ref(ipipe);
    let service_idx = inner_pipe::get_service_idx(ipipe);
    
    events::emit_response(service_idx, req_ipipe_idx, req_seq_num, cli_host_ref, srv_host_ref, tc_ref, ipipe_ref, peer_ipipe_ref, data, cid);

    // Update stats for debugging.
    inner_pipe::inc_emit_cnt(ipipe);

    kvalues::new()
  }

  // Transmit a notification toward the peer (no response expected).
  //
  // The encoding of the 'data' depends on the service.
  public(friend) fun send_notification(_ipipe: &InnerPipe, _data: &vector<u8>, _kvargs: &KValues, _ctx: &mut TxContext): KValues
  {
    kvalues::new()
  }

  // === Private Functions ===

  // === Test Functions ===  

}