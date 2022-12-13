// For now, just focusing on getting the SDKs dependencies right, code is meaningless.
use std::str::FromStr;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};

// High-Level Design (very rough for now, likely to evolve):
//
//    - Create a DTPClient for every committe intended to be used.
//
//    - Use a DTPClient to access its various APIs e.g. dtp_client.connection_api()
//
//    - A Shared Object on the Sui network can have one or more local handles.
//
//      Example: connection_api.get_peer_node_by_address() creates a local
//               handle of an existing Sui Node Shared Object that belongs
//               to someone else.
//
//      When an handle is created it copies a subset of fields from the network object.
//
//      These fields can change only when the handle update() method is successfully
//      called.
//
//      Since the same network object can have multiple handles, it is possible
//      to, as an example, identify change in a field using two handles.

#[derive(Debug)]
pub struct PeerNodeHandle {
    pub id: ObjectID,
}

pub struct OwnNodeHandle {
    pub id: ObjectID,
}

// Provides all the DTP SDK APIs.
pub struct DTP {
    connection_api: ConnectionApi,
}

impl DTP {
    pub fn new() -> Result<Self, anyhow::Error> {
        let connection_api = ConnectionApi;

        Ok(DTP { connection_api })
    }

    pub fn connection_api(&self) -> &ConnectionApi {
        &self.connection_api
    }
}
pub struct ConnectionApi;

impl ConnectionApi {
    // Get an handle of a DTP Node own by a peer on the network.
    //
    // The handle is used for doing operations such as ping the node, create connections,
    // block the node with the firewall etc...
    //
    pub async fn get_peer_node_by_address(
        &self,
        _address: SuiAddress,
    ) -> Result<PeerNodeHandle, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        Ok(PeerNodeHandle {
            id: ObjectID::from_str("0x6205fc058b205227d7b7bd5b4e7802f0055157c6")?,
        })
    }

    // Get an handle of a DTP Node that you own and that is expected to already
    // be on the network.
    pub async fn get_own_node_by_address(
        &self,
        _address: SuiAddress,
    ) -> Result<OwnNodeHandle, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        Ok(OwnNodeHandle {
            id: ObjectID::from_str("0x6205fc058b205227d7b7bd5b4e7802f0055157c6")?,
        })
    }

    // Create a new DTP Node on the network that
    // you will own.
    pub async fn create_node(&self) -> Result<OwnNodeHandle, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        Ok(OwnNodeHandle {
            id: ObjectID::from_str("0x6205fc058b205227d7b7bd5b4e7802f0055157c6")?,
        })
    }

    pub fn ping(
        &self,
        _own_node: &OwnNodeHandle,
        _peer_node: &PeerNodeHandle,
    ) -> Result<bool, anyhow::Error> {
        Ok(true)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dtp_instantiation() -> Result<(), anyhow::Error> {
        let _dtp = DTP::new()?;
        Ok(())
    }

    #[test]
    fn node_call() {
        // Create a Sui ObjectID.

        // Use it to create a DTP Node Object.

        // Mock a ping to that object.

        //assert_eq!(result, 4);
    }
}
