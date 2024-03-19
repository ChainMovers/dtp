
module dtp::api {

  // === Imports ===
    use sui::tx_context::{TxContext};

    use dtp::kvalues::{Self};
    use dtp::host::{Host};
    use dtp::transport_control::{TransportControl};
    use dtp::pipe::{Pipe};
    use dtp::inner_pipe::{InnerPipe};

    use dtp::conn_objects::{ConnObjects};

  // === Friends ===

  // === Errors ===

  // === Constants ===

  // === Structs ===

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  
  // Create a new Host
  //
  // Returns the "Host Address", which serve a similar purpose as an "IP address".
  public fun create_host( args: vector<u8>, ctx: &mut TxContext) : (address, vector<u8>)
  //public fun create_host( ctx: &mut TxContext) : address
  {
    let kvargs = kvalues::from_bytes(&args);    
    let (host_addr, kvalues) = dtp::api_impl::create_host(&kvargs,ctx);
    (host_addr, kvalues::to_bytes(&kvalues))
  }

  // Functions to add services to an Host.
  public fun add_service_ping(host: &mut Host, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::add_service_ping(host, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // JSON-RPC 2.0 service
  public fun add_service_json_rpc(host: &mut Host, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::add_service_json_rpc(host, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // Attempt to open a bi-directional client/server connection.
  //
  // This operation is all on-chain, therefore there is no guarantee that the
  // server is actually running. It is recommended to check first the health 
  // status of the server Host.
  //
  // Returns:
  //   IDs of all objects needed to start exchanging data (TransportControl, Pipes, InnerPipes...).
  //   (These IDs can also be recovered through slow discovery).
  //
  public fun open_connection(service_idx: u8, cli_host: &mut Host, srv_host: &mut Host, args: vector<u8>, ctx: &mut TxContext): vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::open_connection(service_idx, cli_host, srv_host, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // Transmit a request toward the server.
  //
  // The encoding of the 'data' depends on the service.
  public fun send_request(service_idx: u8, data: &vector<u8>, ipipe: &mut InnerPipe, args: vector<u8>, ctx: &mut TxContext): vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::send_request(service_idx, data, ipipe, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // Transmit a response toward the client.
  //
  // The encoding of the 'data' depends on the service.
  public fun send_response(service_idx: u8, data: &vector<u8>, seq_number: u64, ipipe: &mut InnerPipe, args: vector<u8>, ctx: &mut TxContext): vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::send_response(service_idx, data, seq_number, ipipe, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // Transmit a notification toward the peer (no response expected).
  //
  // The encoding of the 'data' depends on the service.
  public fun send_notification(service_idx: u8, data: &vector<u8>, ipipe: &mut InnerPipe, args: vector<u8>, ctx: &mut TxContext): vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::send_notification(service_idx, data, ipipe,&kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }


  // Sync Protocol
  //
  // Any end-point must perform the following two steps from time to time:
  //  1) Call fast_sync_ipipe() for every owned ipipe with its related owned pipe.
  //  2) Call slow_sync_pipe() for the owned pipe and shared transport control.
  public fun fast_sync_ipipe(ipipe: &mut InnerPipe, pipe: &mut Pipe, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::fast_sync_ipipe(ipipe, pipe, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  public fun slow_sync_pipe(pipe: &mut Pipe, tc: &mut TransportControl, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::slow_sync_pipe(pipe, tc, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }


  // Close of a connection.
  //
  // Closing of a connection should be done by both the client and server (in any order).
  //
  // Once a side initiate a closure, the other side will receive an event instructing to 
  // follow up with its own closure call.
  //
  // An half-closed connection is forced closed after a timeout (in the order of epochs).
  //
  // Upon normal first side closure:
  //   - The caller loose ownership of its Pipe and InnerPipes objects. These are transfered
  //     to a DTP DAO for security reason (prevent further transfer). The objects are eventually
  //     deleted after a fair data retention time. The DAO participants are rewarded with the
  //     storage fund recovered.
  //
  //   - The caller will immediately be unable to send more data. The peer will *eventually* be
  //     blocked. Depending of the service, blocking will happen after a few epochs, MBytes or 
  //     response/request limit reached.
  //
  // Upon normal second side closure:
  //   - Both sides will no longuer be able to transfer any data.
  //   - The escrow is run a last time with consideraton that both side followed the protocol.
  //
  // Upon half-closed connection timeout:
  //   - The escrow is run a last time with consideration that one side side failed to follow the protocol.
  //   - An endpoint cannot delete its Pipe and InnerPipes objects. They are instead to be
  //     transfered to the DTP DAO for disposal.  
  //

  public(friend) fun close_ipipe(ipipe: InnerPipe, pipe: &mut Pipe, args: vector<u8>, ctx: &mut TxContext ) : vector<u8> {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::close_ipipe(ipipe, pipe, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  public(friend) fun close_pipe(pipe: &mut Pipe, tc: &mut TransportControl, args: vector<u8>, ctx: &mut TxContext) : vector<u8> {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::close_pipe(pipe, tc, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }
    
  public fun close_connection(service_idx: u8, host: &mut Host, peer_host: &Host, tc: &mut TransportControl, args: vector<u8>, ctx: &mut TxContext): vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::close_connection(service_idx, host, peer_host, tc, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // === Private Functions ===

  // === Test Functions ===  

}