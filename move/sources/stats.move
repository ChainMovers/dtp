module dtp::stats {
    struct ConnectionAcceptedStats has store {
        con_accepted: u64, // Normally accepted connection.
        con_accepted_lru: u64, // Accepted after LRU eviction of another connection.                
    }

    public(friend) fun connection_accepted_stats_sum(stats: &ConnectionAcceptedStats) : u64 {
        stats.con_accepted + 
        stats.con_accepted_lru
    }

    struct ConnectionClosedStats has store {
        con_closed_srv: u64, // Successful close initiated by server.
        con_closed_cli: u64, // Successful close initiated by client.
        con_closed_exp: u64, // Normal expiration initiated by protocol (e.g. Ping Connection iddle).
        con_closed_lru: u64, // Close initiated by least-recently-used (LRU) algo when cons limit reach.
        con_closed_srv_sync_err: u64,  // Server caused a sync protocol error.
        con_closed_clt_sync_err: u64,  // Client caused a sync protocol error.
    }

    public(friend) fun connection_closed_stats_sum(stats: &ConnectionClosedStats) : u64 {
        stats.con_closed_srv + 
        stats.con_closed_cli + 
        stats.con_closed_exp + 
        stats.con_closed_lru + 
        stats.con_closed_srv_sync_err + 
        stats.con_closed_clt_sync_err
    }

    struct ConnectionRejectedStats has store {
        con_rej_host_max_con: u64, // Max Host connection limit reached.
        con_rej_srv_max_con: u64,  // Max Service connection limit reached.
        con_rej_firewall: u64,     // Firewall rejected. TODO more granular reasons.
        con_rej_srv_down: u64,     // Connection requested while server is down.
        con_rej_cli_err: u64,      // Error in client request.
        con_rej_cli_no_fund: u64,  // Client not respecting funding SLA.
    }

    public(friend) fun  connection_rejected_stats_sum(stats: &ConnectionRejectedStats) : u64 {
        stats.con_rej_host_max_con + 
        stats.con_rej_srv_max_con + 
        stats.con_rej_firewall + 
        stats.con_rej_srv_down + 
        stats.con_rej_cli_err + 
        stats.con_rej_cli_no_fund
    }
}