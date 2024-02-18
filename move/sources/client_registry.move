module dtp::client_registry {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    //
    // Owned object. Intended as storage of useful key-value for a DTP client.
    //
    // As an example, this is how a client find its own localhost (stored in the blob)
    //
    // DTP will be tested with only one client registry owned per Sui address.
    // It might work with more than one, but it is not intended to be supported
    // on short term (the DTP SDK will prevent to create more than one).
    //
    // TODO Add general purpose key-value once problem with validators are iron out.
    public struct Registry has key, store {
      id: UID,
      localhost_blob: vector<u8>,
    }

    // Constructors
    fun init(_ctx: &mut TxContext) { /* NOOP */ }

    public(friend) fun new(ctx: &mut TxContext) : Registry {
        Registry {
            id: object::new(ctx),
            localhost_blob: vector[],
        }
    }

    public(friend) fun delete(object: Registry) {
        let Registry { id, localhost_blob: _ } = object;
        object::delete(id);
    }

    public entry fun create( ctx: &mut TxContext ) { 
        let new_obj = new(ctx);
        transfer::transfer(new_obj, tx_context::sender(ctx));
    }

    public entry fun set_localhost_blob( registry: &mut Registry, blob : vector<u8> ) {
        registry.localhost_blob = blob;
    }
}
