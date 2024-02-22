  // === Imports ===

  // === Friends ===

  // === Errors ===

  // === Constants ===

  // === Structs ===

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  // === Private Functions ===

  // === Test Functions ===  


module dtp::weak_ref { 
  // === Imports ===
    use sui::object::{Self,ID};
    use dtp::errors::{Self};

  // === Friends ===
    friend dtp::transport_control;
    friend dtp::pipe;
    friend dtp::inner_pipe;
    friend dtp::host;

  // === Errors ===

  // === Constants ===

  // === Structs ===
    struct WeakRef has copy, store, drop {
      // Refer to a Sui object, but can't assume it still exists (e.g. was deleted).
      //
      // Flags mapping
      //   Lowest 2 bits are reserved for weak reference management:
      //
      //     Bit1  Bit0
      //     ==========
      //       0    0   Reference was not initialized
      //       0    1   Reference was initialized, but object does not exist (likely deleted).
      //       1    X   Reference is considered valid and object is last known to exist.
      //
      //   The highest 6 bits [Bit8..Bit3] can mean anything the user wants.
      //   See set_flags_user() and get_flags_user().
      //
      // Reference is an address, which can easily be converted from/to ID.
      flags: u8,
      reference: address,
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
    public(friend) fun new( id: &ID ): WeakRef {
        WeakRef {
            flags: 0x10,
            reference: object::id_to_address(id),
        }
    }

    public(friend) fun new_from_address( reference: address ): WeakRef {
        WeakRef {
            flags: 0x10,
            reference,
        }
    }

    public(friend) fun new_from_obj<T: key>(obj: &T): WeakRef {
        new_from_address(object::id_to_address(object::borrow_id<T>(obj)))
    }

    public(friend) fun new_empty(): WeakRef {
        WeakRef {
            flags: 0,
            reference: @0x0,
        }
    }


    // Set the reference toward an object.
    public(friend) fun set(self: &mut WeakRef, id: &ID) {
        // Write 0x10 in lowest 2 bits, preserve the rest.
        self.flags = (self.flags & 0xFCu8) | 0x10u8;
        self.reference = object::id_to_address(id);
    }

    public(friend) fun clear(self: &mut WeakRef) {
        // Does not really zero the address/reference... just set a flag to remember 
        // it was deleted.
        //
        // The address is kept to help traceability/debugging.
        //
        // Write 0x01 in lowest 2 bits, preserve the rest.
        self.flags = (self.flags & 0xFCu8) | 0x01u8;        
    }

    // Write a user value into the 6 MSB of flags.
    // Value range is [0..63]
    public(friend) fun set_flags_user(self: &mut WeakRef, value: u8) {        
        let value = value << 2;
        self.flags = (self.flags & 0x03u8) | (value & 0xFCu8);
    }

    // The value stored in the 6 MSB of flags.
    // Return value range is [0..63]
    public(friend) fun get_flags_user(self: &WeakRef) : u8 {
        (self.flags >> 2) & 0x3Fu8
    }


    public(friend) fun id(self: &WeakRef) : ID
    {
        // Will return a copy of the id even if the reference was cleared.
        // Different than some() that will assert when cleared.
        object::id_from_address(self.reference)
    }

    public(friend) fun get_address(self: &WeakRef) : address
    {
        // Will return a copy of the address even if the reference was cleared.
        // Different than some() that will assert when cleared.
        self.reference
    }

    public(friend) fun is_set(self: &WeakRef): bool
    {
        self.flags & 0x10u8 == 0x10u8
    }

    public(friend) fun is_clear(self: &WeakRef): bool
    {
        self.flags & 0x10u8 == 0x00u8
    }

    public(friend) fun some(self: &WeakRef) : ID
    {
        assert!(is_set(self), errors::EInvalidAccessOnNone());
        object::id_from_address(self.reference)
    }

    public(friend) fun some_address(self: &WeakRef) : address
    {
        assert!(is_set(self), errors::EInvalidAccessOnNone());
        self.reference
    }

  // === Private Functions ===

  // === Test Functions ===    



}