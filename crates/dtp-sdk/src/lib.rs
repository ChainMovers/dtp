// For now, just focusing on getting the SDKs dependencies right, code is meaningless.
use sui_sdk::types::base_types::ObjectID;

#[derive(Debug)]
pub struct Node {
    pub id : ObjectID,
}

impl Node {
  pub fn ping() -> bool {
    return true;
  }
}

#[cfg(test)]
mod tests {
    //use super::*;

    #[test]
    fn node_call() {
        // Create a Sui ObjectID.

        // Use it to create a DTP Node Object.

        // Mock a ping to that object.
        
        //assert_eq!(result, 4);
    }
}
