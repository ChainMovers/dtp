module dtp::consts {
    // Limit number of active connection a service can handle.
    //
    // This is to stay below max_move_object_size.
    //
    // Planning for ~40 bytes of data per connection. So:
    //   4096 * 40 = 164 KB
    //
    // As of ~2024, max_move_object_size is 256000 Bytes. For latest check:    
    //    https://github.com/MystenLabs/sui/blob/main/crates/sui-protocol-config/src/snapshots
    //  
    // If you need more connections, consider creating additional hosts.
    const C_MAX_CONNECTION_PER_SERVICE: u16 = 4096;    
    public fun MAX_CONNECTION_PER_SERVICE() : u16 { C_MAX_CONNECTION_PER_SERVICE }
    
    const C_MAX_SERVICE_PER_HOST: u8 = 16;
    public fun MAX_SERVICE_PER_HOST() : u8 { C_MAX_SERVICE_PER_HOST }

    public fun MAX_CONNECTION_PER_HOST() : u32 {
        (C_MAX_CONNECTION_PER_SERVICE as u32) * (C_MAX_SERVICE_PER_HOST as u32)
    }
}