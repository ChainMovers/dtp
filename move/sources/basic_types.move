module dtp::basic_types {
    use std::option::{Self,Option};
    use sui::object::ID;

    public struct WeakID has store, drop {
      // Refer to a Sui object, but can't assume it still exists (e.g. was deleted).
      //
      // flags mapping:
      //   The lowest 2 bits are reserved for weak reference itself.
      //      00 Reference was not initialized
      //      01 Reference was initialized, but object is now deleted.
      //      1X Reference is considered valid.
      //
      //   The highest 6 bits can mean anything the user wants.
      //   See set_flags_user() and get_flags_user().
      flags: u8,
      wid: ID,
    }

    // Write the value into the 6 MSB of flags.
    // Value range is [0..63]
    public(friend) fun set_flags_user(self: &mut WeakID, value: u8) {        
        let value = value << 2;
        self.flags = (self.flags & 0x03) | (value & 0xFC);
    }

    // The value stored in the 6 MSB of flags.
    // Return value range is [0..63]
    public(friend) fun get_flags_user(self: &WeakID) : u8 {
        (self.flags >> 2) & 0x3F
    }

    public(friend) fun set_id(self: &mut WeakID, id: ID) {
        self.flags = 0x10;
        self.wid = id;
    }

    public(friend) fun clear_id(self: &mut WeakID, id: ID) {
        // Does not really clear it... just set teh flags to remember it was deleted.
        // The wid is kept to help traceability/debugging.
        self.flags = 0x01;
        self.wid = id;
    }
    
    public(friend) fun get_id(self: &WeakID) : Option<ID>
    {
        if (self.flags & 0x10 == 0x0) {
            option::none()
        } else {
            option::some(self.wid)
        }        
    }

}