module dtp::api {

  // === Imports ===
    use sui::tx_context::{TxContext};

    use dtp::kvalues::{Self};
    use dtp::host::{Host};
    use dtp::conn_objects::{ConnObjects};

  // === Friends ===

  // === Errors ===

  // === Constants ===

  // === Structs ===

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  // Functions to add services to an Host.
  public entry fun add_service_ping(host: &mut Host, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::add_service_ping(host, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // JSON-RPC 2.0 service
  public entry fun add_service_json_rpc(host: &mut Host, args: vector<u8>, ctx: &mut TxContext) : vector<u8>
  {
    let kvargs = kvalues::from_bytes(&args);
    let ret_value = dtp::api_impl::add_service_json_rpc(host, &kvargs, ctx);
    kvalues::to_bytes(&ret_value)
  }

  // Returns IDs of objects needed to start exchanging data (TransportControl, Pipes, InnerPipes...).  
  public entry fun open_connection(service_idx: u8, cli_host: &mut Host, srv_host: &mut Host, args: vector<u8>, ctx: &mut TxContext): (ConnObjects, vector<u8>)
  {
    let kvargs = kvalues::from_bytes(&args);
    let (conn_objects, ret_value) = dtp::api_impl::open_connection(service_idx, cli_host, srv_host, &kvargs, ctx);
    (conn_objects, kvalues::to_bytes(&ret_value))
  }

  // === Private Functions ===

  // === Test Functions ===  

}