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
    use sui::table::{Self,Table};
        
    use sui::transfer::{Self};
    use sui::tx_context::{Self,TxContext};
    use sui::linked_table::{Self,LinkedTable};

    // To avoid circular reference, this Host module *must* not use: 
    //     dtp::transport_control
    //     dtp::pipe 
    //     dtp::inner_pipe

    use dtp::stats::{Self,ConnAcceptedStats, ConnRejectedStats, ConnClosedStats};
    use dtp::weak_ref::{Self,WeakRef};
    use dtp::consts::{Self};
    use dtp::kvalues::{KValues};
    
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
    struct Connection has copy, drop, store {      
      tx: WeakRef, // Reference on the TransportControl (for slow discovery).
    }

    struct Service has store {
        service_idx: u8,

        // Each connection requested increments one member of either conn_accepted or conn_rejected.
        conn_accepted: ConnAcceptedStats,
        conn_rejected: ConnRejectedStats,

        // Every conn_accepted are either represented in 'conns'
        // container or an increment of one member of conn_closed.
        conn_closed: ConnClosedStats,
        
        // Active connections 
        conns: LinkedTable<ID,Connection>,

        // Recently closed connections (for debug purpose).
        conns_recent_closed: LinkedTable<ID,Connection>,
    }

    struct HostConfig has copy, drop, store {
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

        creator: address,

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

        // Services provided by this Host.
        //   key is a service idx [1..253] ( See service_type.move )        
        services: Table<u8, Service>,
    }


  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

    public(friend) fun new(ctx: &mut TxContext) : Host {
        Host {
            id: object::new(ctx),
            flgs: 0,
            creator: tx_context::sender(ctx),
            config: HostConfig {
                max_con: consts::MAX_CONNECTION_PER_HOST(),
            },
            services: table::new(ctx),
        }
    }

    #[allow(lint(share_owned))]
    public(friend) fun new_transfered( ctx: &mut TxContext ): WeakRef 
    {
      let new_obj = dtp::host::new(ctx);
      let new_obj_ref = weak_ref::new_from_address(uid_to_address(&new_obj.id));
      transfer::share_object(new_obj);
      new_obj_ref
    }

    public(friend) fun upsert_service(self: &mut Host, service_idx: u8, _args: &KValues, ctx: &mut TxContext )
    {     
      if (!table::contains(&self.services, service_idx )) {
        //assert!(table::contains(&self.services, service_idx) == false, 1);
        table::add(&mut self.services, service_idx, Service{
          service_idx: service_idx,
          conn_accepted: stats::new_conn_accepted_stats(),
          conn_rejected: stats::new_conn_rejected_stats(),
          conn_closed: stats::new_conn_closed_stats(),
          conns: linked_table::new(ctx),
          conns_recent_closed: linked_table::new(ctx),
        });
      }

      // TODO Update/replace when already in table.
    }

    public(friend) fun creator(host: &Host): address {
        host.creator
    }

    public(friend) fun is_caller_creator(host: &Host, ctx: &TxContext): bool {
        tx_context::sender(ctx) == host.creator
    }

  // === Private Functions ===

  // === Test Functions ===  

}

#[test_only, allow(unused_field, unused_use)]
module dtp::test_host {

    //use sui::transfer;
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

            let _new_host_ref = host::new_transfered( ctx );
        
            // admnistrator address must be the creator.
            //assert!(host::creator(&new_host) == creator, 1);            
        };

        test_scenario::end(scenario_val);
    }

}
