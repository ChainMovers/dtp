// This is the most "visible" DTP shared object.
//
// The address of the Host object is the one used when
// targeting an "<Host Object ID>:port" service.
//
// Typical next step with the DTP API will be ping or
// create a connection with that Host object.
//
#[allow(unused_field, unused_use, lint(share_owned))]
module dtp::host {

    use sui:: {
        object::{Self, UID, ID},
        transfer::{Self},
        tx_context::{TxContext},
        linked_table::{LinkedTable},        
        dynamic_field as df,
    };    

    use dtp:: {
        service_type::{ServiceType},
        stats::{ConnectionAcceptedStats, ConnectionRejectedStats, ConnectionClosedStats},
        basic_types::{WeakID},
    };
    
    #[test_only]
    friend dtp::test_host;
    #[test_only]
    friend dtp::test_transport_control;


    // Public Shared  Object
    public struct AdminCap has key, store {
        id: UID,
    }

    public struct Connection has store {        
        tctrl_id: WeakID,
        service_id: WeakID,
    }

    public struct Service has store {
        srvc_type: ServiceType,

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

    public struct HostConfig has store {
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
        max_con: u16,

    }

    public struct Host has key, store {
        id: UID,

        flgs: u8, // DTP version+esc flags always after UID.


        // Settings that may change from time to time.
        //

        // Aggregated connections statistic (updated periodically).
        // TODO

        // *************************************************************
        // Information that do not change for the lifetime of the  Node.
        // *************************************************************

        // Creation time info
        // TODO

        // Service Level Agreements
        // TODO

        // Future proofing.
    }

    // Constructors
    fun init(_ctx: &mut TxContext) { /* NOOP */ }

    public(friend) fun new(ctx: &mut TxContext) : Host {
        Host {
            id: object::new(ctx),
            flgs: 0
        }
    }

    public entry fun create( ctx: &mut TxContext ) { transfer::share_object<Host>(new(ctx)); }
    
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
            assert!(host::adm(&new_host) == creator, 1);

            transfer::share_object( new_host );
        };

        test_scenario::end(scenario_val);
    }

}
