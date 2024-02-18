#[allow(unused_const, unused_field)]
module dtp::service_type {

    public struct ServiceType has store{
        name: vector<u8>, // Human readable name (e.g. "HTTP", "JSON-RPC 2.0", etc...)

        // Protocol port. 
        //
        // Intended to mimic https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
        //
        // Example:
        //      <Host ID Address>:443  --> HTTPS server
        //      <Host ID Address>:22   --> SSH
        port: u32, 

        // The end-user and DTP API uses the protocol port.
        //
        // The DTP SDKs convert the port to idx when interacting 
        // with the Move modules.
        //
        // This is to optimize fast service object access using a vector.
        //
        // [1..254] (0 and 255 reserved)
        idx: u8,
    }

    // TODO Searcheable list of supported type. 

    // Think hard before adding a new type... these are forever.

    // UDP Tunelling.    
    const SERVICE_TYPE_UDP_IDX: u8 = 1;
    const SERVICE_TYPE_UDP_NAME: vector<u8> = b"UDP";
    const SERVICE_TYPE_UDP_PORT: u32 = 1;

    // Remote Procedure Call (RPC)
    const SERVICE_TYPE_JSON_RPC_2_0_IDX: u8 = 2;
    const SERVICE_TYPE_JSON_RPC_2_0_NAME: vector<u8> = b"JSON-RPC 2.0";
    const SERVICE_TYPE_JSON_RPC_2_0_PORT: u32 = 2;

    // GraphQL Service
    const SERVICE_TYPE_GRAPHQL_IDX: u8 = 3;
    const SERVICE_TYPE_GRAPHQL_NAME: vector<u8> = b"GRAPHQL";
    const SERVICE_TYPE_GRAPHQL_PORT: u32 = 3;

    // HTTP (optionally encrypted)
    const SERVICE_TYPE_HTTP_IDX: u8 = 4;
    const SERVICE_TYPE_HTTP_NAME: vector<u8> = b"HTTP";
    const SERVICE_TYPE_HTTP_PORT: u32 = 80;

    // HTTPS (always encrypted)
    const SERVICE_TYPE_HTTPS_IDX: u8 = 5;
    const SERVICE_TYPE_HTTPS_NAME: vector<u8> = b"HTTPS";
    const SERVICE_TYPE_HTTPS_PORT: u32 = 443;

    // Secure Shell Protocol
    const SERVICE_TYPE_SSH_IDX: u16 = 6;
    const SERVICE_TYPE_SSH_NAME: vector<u8> = b"SSH";
    const SERVICE_TYPE_SSH_PORT: u32 = 22;

    // Ping
    const SERVICE_TYPE_ECHO_IDX: u16 = 7;
    const SERVICE_TYPE_ECHO_NAME: vector<u8> = b"ECHO";
    const SERVICE_TYPE_ECHO_PORT: u32 = 7;

    // File Transfer
    const SERVICE_TYPE_FTP_IDX: u16 = 8;
    const SERVICE_TYPE_FTP_NAME: vector<u8> = b"FTP";
    const SERVICE_TYPE_FTP_PORT: u32 = 21;
}