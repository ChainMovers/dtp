module dtp::user_registry {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

   const REGISTRY_INVALID_ADDRESS: address = @0x0;

    //
    // Owned object. Intended as storage of useful key-value for a DTP client.
    //
    // As an example, this is how a client find its own localhost.
    //
    // DTP will be tested with only one client registry owned per Sui address.
    //
    // It might work with more than one, but it is not intended to be supported
    // on short term (the DTP SDK will prevent to create more than one).
    struct UserRegistry has key, store {
      id: UID,
      host_addr: address,
    }

    // Constructors
    public fun new(ctx: &mut TxContext) : UserRegistry {
        UserRegistry {
            id: object::new(ctx),
            host_addr: REGISTRY_INVALID_ADDRESS
        }
    }

    public fun delete(self: UserRegistry) {
        let UserRegistry { id, host_addr: _ } = self;
        object::delete(id);
    }

    public fun new_and_transfer( localhost_id: ID, ctx: &mut TxContext ) { 
        let new_obj = new(ctx);
        set_host_addr_with_id(&mut new_obj, &localhost_id);
        transfer::transfer(new_obj, tx_context::sender(ctx));
    }

    public fun set_host_addr( registry: &mut UserRegistry, host_addr: address ) {
        registry.host_addr = host_addr;
    }

    public fun set_host_addr_with_id( registry: &mut UserRegistry, host_id: &ID ) {
        registry.host_addr = object::id_to_address(host_id);
    }

    public fun get_host_addr( registry: &UserRegistry ): address {
        registry.host_addr
    }
}
