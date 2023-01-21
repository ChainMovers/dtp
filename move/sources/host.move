// This is the most "visible" DTP shared object.
//
// The address of the Host object is the one used when
// targeting an "<Host Object ID>:port" service.
//
// Typical next step with the DTP API will be ping or
// create a connection with that Host object.
//
module dtp::host {

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    #[test_only]
    friend dtp::test_host;
    #[test_only]
    friend dtp::test_transport_control;

    // Put a limit on number of connection that a single host
    // can handle.
    //
    // This is to avoid poor performance or high gas cost when:
    //  - iterating all connections (e.g. firewall processing)
    //  - table of connections would exceed MAX_MOVE_OBJECT_SIZE
    //
    // Planning for ~40 bytes of data per connection in a Host object. So:
    //
    //   4096 * 40 = 164 KB which must remain below MAX_MOVE_OBJECT_SIZE.
    //
    // See:
    // https://github.com/MystenLabs/sui/blob/main/crates/sui-protocol-constants/src/lib.rs
    //
    // Why 4096? because it fits in 12 bits for some potential indexing trick.
    //
    // Need to handle more connections?
    // 
    // Every service in a Host can optionally be added to a HostGroup.
    //
    // If a Host is too busy, the connection initiator can look
    // into the HostGroup for an alternative way to reach the service.
    //
    // Therefore the limit is 4096 * 4096 = ~16.7 million connections for 
    // one centralized service (the practical limit is likely lower...).
    //
    const MAX_CONNECTION_PER_HOST : u16 = 4096; 
    const MAX_HOST_PER_HOSTGROUP : u16 = 4096;

    // Default is 25% of MAX at Node initialization and can be later reconfigured.
    const MAX_CONNECTION_PER_HOST_DEFAULT : u16 = 1024;

    // Public Shared  Object
    struct WeakReference has store, drop {
      // Refer to a Sui object without holding a reference to it.
      //
      // This information is often intended to be read by an off-chain client
      // who can asynchronously try to query or create transaction on that object.
      //   
      // The Flags bitmap interpretation mostly depends of the context of the reference,
      // except for the value 0x00 being reserved to mean the ID is undefined/invalid.
      flags: u8,
      wid: ID,
    }

    struct HostGroup has key, store {
        id: UID,
        hosts: vector<WeakReference>,
    }

    public(friend) fun delete(object: HostGroup) {
        let HostGroup { id, hosts: _ } = object;
        object::delete(id);
    }

    struct Host has key, store {
        id: UID,

        flgs: u8, // DTP version+esc flags always after UID.

        // The administrator has more control through transactions.
        adm: address, 

        // Real-Time statistics.
        // 
        // rejected connection can be calculated as (requested - created).
        // created always >= deleted
        con_req: u64, 
        con_add: u64,
        con_del: u64,
        con_rcy: u64,

        // Settings that may change from time to time.
        //
        // If after a change the connections_active > max_connections_active, then no
        // new connection will be allowed. Existing connections are not forced to terminate
        // butwill be closed if becoming inactive.
        max_con: u16,

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
            flgs: 0,
            adm: tx_context::sender(ctx),
            con_req: 0, 
            con_add: 0,
            con_del: 0,
            con_rcy: 0,
            max_con: MAX_CONNECTION_PER_HOST_DEFAULT,
        }
    }

    public entry fun create( ctx: &mut TxContext ) { transfer::share_object<Host>(new(ctx)); }

    // Accessors
    public(friend) fun adm(self: &Host) : address { self.adm }
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
