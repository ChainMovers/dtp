module dtp::kvalues { 
  // === Imports ===
    use std::string::{String};
    use std::option::{Self, Option};
    use std::vector;

    // use dtp::errors::{Self};

  // === Friends ===
    friend dtp::api;

  // === Errors ===

  // === Constants ===

  // === Structs ===

    // TODO Implement BCS + typescript and rust codec (helpers).
    struct KValues has copy, store, drop {
      keys_bool: vector<String>,

      keys_u64: vector<String>, 
      values_u64: vector<u64>,

      keys_str: vector<String>,
      values_str: vector<String>,      
    }

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===
    public fun new(): KValues {
      KValues {
        keys_bool: vector::empty(),

        keys_u64: vector::empty(),
        values_u64: vector::empty(),

        keys_str: vector::empty(),
        values_str: vector::empty(),
      }
    }

    public fun from_bytes(_bytes: &vector<u8> ): KValues {
      // TODO Not implemented      
      dtp::kvalues::new()     
    }
    
    public fun to_bytes(_self: &KValues): vector<u8> {
      // TODO Not implemented      
      vector::empty()
    }

    public fun get_bool( self: &KValues, key: &String ): bool {
      // Linear search, acceptable assuming small number of keys.
      let i: u64 = 0;
      let ret_value = false;
      let length = vector::length( &self.keys_bool );
      while (i < length) {
        if (vector::borrow<String>(&self.keys_bool, i) == key) {
          ret_value = true;
          break
        };
        i = i + 1;
      };
      ret_value
    }

    public fun get_u64( self: &KValues, key: &String ): Option<u64> {
      // Linear search, acceptable assuming small number of keys.
      let i: u64 = 0;
      let ret_value = option::none<u64>();
      let length = vector::length( &self.keys_u64 );
      while (i < length) {
        if (vector::borrow<String>(&self.keys_u64, i) == key) {
          let value = vector::borrow<u64>(&self.values_u64, i);
          ret_value = option::some<u64>(*value);
          break
        };
        i = i + 1;
      };
      ret_value
    }

    public fun get_str( self: &KValues, key: &String ): Option<String> {
      // Linear search, acceptable assuming small number of keys.
      let i: u64 = 0;
      let ret_value = option::none<String>();
      let length = vector::length( &self.keys_str );
      while (i < length) {
        if (vector::borrow<String>(&self.values_str, i) == key) {
          let value = vector::borrow<String>(&self.values_str, i);
          ret_value = option::some<String>(*value);
          break
        };
        i = i + 1;
      };
      ret_value
    }

  // === Private Functions ===

  // === Test Functions ===    

}