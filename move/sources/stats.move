module dtp::stats {
  // === Imports ===

  // === Friends ===    
    friend dtp::host;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    struct ConnAcceptedStats has copy, drop, store {
        conn_accepted: u64, // Normally accepted connection.
        conn_accepted_lru: u64, // Accepted after LRU eviction of another connection.                
    }

    struct ConnClosedStats has copy, drop, store {
        conn_closed_srv: u64, // Successful close initiated by server.
        conn_closed_cli: u64, // Successful close initiated by client.
        conn_closed_exp: u64, // Normal expiration initiated by protocol (e.g. Ping Connection iddle).
        conn_closed_lru: u64, // Close initiated by least-recently-used (LRU) algo when cons limit reach.
        conn_closed_srv_sync_err: u64,  // Server caused a sync protocol error.
        conn_closed_clt_sync_err: u64,  // Client caused a sync protocol error.
    }

    struct ConnRejectedStats has copy, drop, store {
        conn_rej_host_max_con: u64, // Max Host connection limit reached.
        conn_rej_srv_max_con: u64,  // Max Service connection limit reached.
        conn_rej_firewall: u64,     // Firewall rejected. TODO more granular reasons.
        conn_rej_srv_down: u64,     // Connection requested while server is down.
        conn_rej_cli_err: u64,      // Error in client request.
        conn_rej_cli_no_fund: u64,  // Client not respecting funding SLA.
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===


    // Constructors
    public(friend) fun new_conn_accepted_stats(): ConnAcceptedStats {
        ConnAcceptedStats {
            conn_accepted: 0,
            conn_accepted_lru: 0,
        }
    }

    public(friend) fun new_conn_closed_stats(): ConnClosedStats {
        ConnClosedStats {
            conn_closed_srv: 0,
            conn_closed_cli: 0,
            conn_closed_exp: 0,
            conn_closed_lru: 0,
            conn_closed_srv_sync_err: 0,
            conn_closed_clt_sync_err: 0,
        }
    }

    public(friend) fun new_conn_rejected_stats(): ConnRejectedStats {
        ConnRejectedStats {
            conn_rej_host_max_con: 0,
            conn_rej_srv_max_con: 0,
            conn_rej_firewall: 0,
            conn_rej_srv_down: 0,
            conn_rej_cli_err: 0,
            conn_rej_cli_no_fund: 0,
        }
    }

    public(friend) fun conn_accepted_stats_sum(stats: &ConnAcceptedStats) : u64 {
        stats.conn_accepted + 
        stats.conn_accepted_lru
    }

    public(friend) fun conn_closed_stats_sum(stats: &ConnClosedStats) : u64 {
        stats.conn_closed_srv + 
        stats.conn_closed_cli + 
        stats.conn_closed_exp + 
        stats.conn_closed_lru + 
        stats.conn_closed_srv_sync_err + 
        stats.conn_closed_clt_sync_err
    }

    public(friend) fun  conn_rejected_stats_sum(stats: &ConnRejectedStats) : u64 {
        stats.conn_rej_host_max_con + 
        stats.conn_rej_srv_max_con + 
        stats.conn_rej_firewall + 
        stats.conn_rej_srv_down + 
        stats.conn_rej_cli_err + 
        stats.conn_rej_cli_no_fund
    }


  // === Private Functions ===

  // === Test Functions ===  

}