// This is the most "visible" DTP shared object.
//
// The address of the Host object is the one used when
// targeting an "<Host Object ID>:port" service.
//
// Typical next step with the DTP API will be ping or
// create a connection with that Host object.
//
#[allow(unused_field, unused_use)]
module dtp::host {

  // === Imports ===
    use sui::object::{Self, UID, ID, uid_to_address};
        
    //use sui::transfer::{Self};
    use sui::tx_context::{Self,TxContext};
    use sui::linked_table::{LinkedTable};

    //use dtp::service_type::{ServiceType};
    use dtp::stats::{ConnectionAcceptedStats, ConnectionRejectedStats, ConnectionClosedStats};
    use dtp::weak_ref::{WeakRef};
    use dtp::consts::{Self};
    //use dtp::errors::{Self};

  // === Friends ===
    friend dtp::transport_control;

    #[test_only]
    friend dtp::test_host;

    #[test_only]
    friend dtp::test_transport_control;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    // Public Shared  Object
    struct Connection has store {        
        tctrl_id: WeakRef,
    }

    struct Service has store {
        service_idx: u8,

        // Each connection requested increments one member of either con_accepted or con_rejected.
        con_accepted: ConnectionAcceptedStats,
        con_rejected: ConnectionRejectedStats,

        // Every con_accepted are either represented in cons container or
        // an increment of one member of con_closed.
        con_closed: ConnectionClosedStats,
        
        // Active connections 
        cons: LinkedTable<ID,Connection>,

        // Recently closed connections (for debug purpose).
        cons_recent_closed: LinkedTable<ID,Connection>,
    }

    struct HostConfig has store {
        // Configurations that can be changed only by the AdminCap.

        // Maximum number of connection allowed for the whole host.
        //
        // [0..dtp::consts::MAX_CONNECTION_PER_HOST]
        //
        // Change will not trig the immediate closing of existing connections, 
        // it is therefore possible to have temporarly more open connections 
        // than allowed.
        //
        // The protocol will progressively close LRU connections until eventual
        // respect the new limit.        
        max_con: u32,

    }

    struct Host has key, store {
        id: UID,

        flgs: u8, // DTP version+esc flags always after UID.

        owner: address,

        // Creation timestamp (UTC)
        // TODO

        // Last SLA Update timestamp (UTC)
        // TODO

        // Last Server Heartbeat timestamp (UTC)
        // TODO

        // Last Config Update timestamp (UTC) - For debugging purpose.
        // TODO

        // Last Protocol Sync timestamp (UTC) - For debugging purpose.
        // TODO

        // Settings controlled by AdminCap.
        config: HostConfig, 

        // Aggregated connections statistic (updated periodically).
        // TODO

        // Service Level Agreements
        // TODO
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new(ctx: &mut TxContext) : Host {
        Host {
            id: object::new(ctx),
            flgs: 0,
            owner: tx_context::sender(ctx),
            config: HostConfig {
                max_con: consts::MAX_CONNECTION_PER_HOST(),
            },
        }
    }

    public(friend) fun owner(host: &Host): address {
        host.owner
    }

    public(friend) fun is_caller_owner(host: &Host, ctx: &TxContext): bool {
        tx_context::sender(ctx) == host.owner
    }

  // === Private Functions ===

  // === Test Functions ===  

}

#[test_only]
module dtp::test_host {

    use sui::transfer;
    use sui::test_scenario::{Self};

    use dtp::host::{Self};  // DUT

    #[test]
    fun test_instantiation() {
        let creator = @0x1;
        let scenario_val = test_scenario::begin(creator);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, creator);
        {
            let ctx = test_scenario::ctx(scenario);

            let new_host = host::new( ctx );

            // admnistrator address must be the creator.
            assert!(host::owner(&new_host) == creator, 1);

            transfer::share_object( new_host );
        };

        test_scenario::end(scenario_val);
    }

}
