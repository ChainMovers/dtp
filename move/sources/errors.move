module dtp::errors {
  // === Imports ===

  // === Friends ===

  // === Errors ===

  // === Constants ===
    // TODO Could error code be 32 bits?
    // TODO Refactor once public consts are supported.    
    // TODO Consider public(package) once available.
    public fun EOnePipeRequired() : u64 { 1 }    
    public fun EHostAddressMismatch1() : u64 { 2 }    
    public fun EHostAddressMismatch2() : u64 { 3 }    
    public fun EPipeInstanceSame() : u64 { 4 }
    public fun EServiceIdxOutOfRange() : u64 { 5 }
    
  // === Structs ===

  // === Public-Mutative Functions ===

  // === Public-View Functions ===

  // === Admin Functions ===

  // === Public-Friend Functions ===

  // === Private Functions ===

  // === Test Functions ===    

  
}