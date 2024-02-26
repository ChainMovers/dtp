module dtp::api_impl {

  // === Imports ===
    use sui::tx_context::{TxContext};

    use dtp::host::{Host};
    use dtp::transport_control::{Self};
    use dtp::conn_objects::{Self,ConnObjects};
    use dtp::kvalues::{Self,KValues};

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
  public(friend) fun open_connection(service_idx: u8, cli_host: &mut Host, srv_host: &mut Host, _kvargs: &KValues, ctx: &mut TxContext): (ConnObjects, KValues)
  {
    let conn = conn_objects::new();

    // Create the connection. Will emit an event on success
    transport_control::create_best_effort(service_idx, cli_host, srv_host, &mut conn, ctx);

    // TODO Add references in Host object for slow discovery.
    //host::add_connection(cli_host, &conn.transport_control);
    //host::add_connection(srv_host, &conn.transport_control);

    (conn, kvalues::new())
  }

  // === Private Functions ===

  // === Test Functions ===  

}