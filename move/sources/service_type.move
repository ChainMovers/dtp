#[allow(unused_const, unused_field)]
module dtp::service_type {

  // === Imports ===

  // === Friends ===

  // === Errors ===

  // === Constants ===
    // Think hard before adding a new type... these are forever.
    // Add new Service only at the end of the list.
    
    // Invalid Service Type
    const C_SERVICE_TYPE_INVALID_IDX: u8 = 0;
    const C_SERVICE_TYPE_INVALID_NAME: vector<u8> = b"Invalid";
    const C_SERVICE_TYPE_INVALID_PORT: u32 = 0;

    // UDP Tunelling.    
    const C_SERVICE_TYPE_UDP_IDX: u8 = 1;
    const C_SERVICE_TYPE_UDP_NAME: vector<u8> = b"UDP";
    const C_SERVICE_TYPE_UDP_PORT: u32 = 1;

    // Remote Procedure Call (RPC)
    const C_SERVICE_TYPE_JSON_RPC_2_0_IDX: u8 = 2;
    const C_SERVICE_TYPE_JSON_RPC_2_0_NAME: vector<u8> = b"JSON-RPC 2.0";
    const C_SERVICE_TYPE_JSON_RPC_2_0_PORT: u32 = 2;

    // GraphQL Service
    const C_SERVICE_TYPE_GRAPHQL_IDX: u8 = 3;
    const C_SERVICE_TYPE_GRAPHQL_NAME: vector<u8> = b"GRAPHQL";
    const C_SERVICE_TYPE_GRAPHQL_PORT: u32 = 3;

    // HTTP (optionally encrypted)
    const C_SERVICE_TYPE_HTTP_IDX: u8 = 4;
    const C_SERVICE_TYPE_HTTP_NAME: vector<u8> = b"HTTP";
    const C_SERVICE_TYPE_HTTP_PORT: u32 = 80;

    // HTTPS (always encrypted)
    const C_SERVICE_TYPE_HTTPS_IDX: u8 = 5;
    const C_SERVICE_TYPE_HTTPS_NAME: vector<u8> = b"HTTPS";
    const C_SERVICE_TYPE_HTTPS_PORT: u32 = 443;

    // Ping (ICMP Echo Request/Reply)
    const C_SERVICE_TYPE_ECHO_IDX: u8 = 7;
    const C_SERVICE_TYPE_ECHO_NAME: vector<u8> = b"ECHO";
    const C_SERVICE_TYPE_ECHO_PORT: u32 = 7;

    // gRPC
    const C_SERVICE_TYPE_GRPC_IDX: u8 = 8;
    const C_SERVICE_TYPE_GRPC_NAME: vector<u8> = b"GRPC";
    const C_SERVICE_TYPE_GRPC_PORT: u32 = 8;

    // Discard Protocol
    //
    // Connection used to send any data. No guarantees of being process
    // by the receiver. Data retention time is minimized (drop on network 
    // as soon as possible). Sender pays all costs.
    //
    // Intended for testing/benchmarking of sender.
    const C_SERVICE_TYPE_DISCARD_IDX: u8 = 9;
    const C_SERVICE_TYPE_DISCARD_NAME: vector<u8> = b"DISCARD";
    const C_SERVICE_TYPE_DISCARD_PORT: u32 = 9;

    // [10..20] Available

    // File Transfer
    const C_SERVICE_TYPE_FTP_IDX: u8 = 21;
    const C_SERVICE_TYPE_FTP_NAME: vector<u8> = b"FTP";
    const C_SERVICE_TYPE_FTP_PORT: u32 = 21;

    // Secure Shell Protocol
    const C_SERVICE_TYPE_SSH_IDX: u8 = 22;
    const C_SERVICE_TYPE_SSH_NAME: vector<u8> = b"SSH";
    const C_SERVICE_TYPE_SSH_PORT: u32 = 22;

    // !!! Update SERVICE_TYPE_MAX_IDX when appending new service types. !!!
    const C_SERVICE_TYPE_MAX_IDX: u8 = 22;
 
  // === Structs ===
    struct ServiceType has store{
        name: vector<u8>, // Human readable name (e.g. "HTTP", "JSON-RPC 2.0", etc...)

        // Protocol port. 
        //
        // Intended to mimic https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
        //
        // Keep in mind that DTP provide "layer 7" services, so it will not
        // match exactly IANA RFC numbers.abort
        //
        // As an example, DTP can add gRPC specific functionality, while in the IP
        // world it is served by HTTPS.
        //
        // Example:
        //      <Host ID Address>:443  --> HTTPS server
        //      <Host ID Address>:22   --> SSH

        port: u32, 

        // The end-users and DTP API uses the protocol_port.
        //
        // The DTP SDKs convert the port to ServiceTypeIdx when 
        // interacting with the Move modules.
        //
        // This is to optimize fast service object access using a vector.
        //
        // [0..SERVICE_TYPE.length - 1]
        // where SERVICE_TYPE.length <= 256
        //       0 means invalid 
        //       255 is for future use.
        idx: u8,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  // === Private Functions ===

  // === Test Functions ===     
    public fun SERVICE_TYPE_MAX_IDX() : u8 {
        C_SERVICE_TYPE_MAX_IDX
    }
}