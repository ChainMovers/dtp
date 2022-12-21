use derivative::Derivative;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

// Flatten many sub modules/files under the same dtp_core::network module.
//
// Allows to do:
//    use dtp_core::network::{NetworkManager, HostInternal, LocalhostInternal}
//
// Instead of:
//    use dtp_core::network::NetworkManager;
//    use dtp_core::network::host_internal::HostInternal;
//    use dtp_core::network::localhost_internal::LocalhostInternal;
pub use self::host_internal::*;
pub use self::localhost_internal::*;

mod host_internal;
mod localhost_internal;

// NetworkManager
//
// Perform network objects management associated to a single client address.
// Includes creation, deletion, indexing etc...
//
// A client address should be associated to only one NetworkManager instance (to
// prevent some equivocation scenarios).
//
// A Sui network object can have multiple local handles (say to represent the object
// at different point in time), and any handle can be used to interact with the
// latest version of the object on the network.
//
// For every handles in the API there is a one-to-one relationship with
// an 'Internal' version that encapsulate most of the implementation.
//
// Examples:
//     An API dtp-sdk::Host      --- owns a ----> dtp-core::HostInternal
//     An API dtp-sdk::Locahost  --- owns a ----> dtp-core::LocalhostInternal
//
#[derive(Derivative)]
#[derivative(Debug)]
pub struct NetworkManager {
    package_id: ObjectID,
    client_address: SuiAddress,
    #[derivative(Debug = "ignore")]
    sui_client: SuiClient,
}

impl NetworkManager {
    pub async fn new(
        client_address: SuiAddress,
        http_url: &str,
        ws_url: Option<&str>,
    ) -> Result<Self, anyhow::Error> {
        let sui_client = SuiClient::new(http_url, ws_url, None).await?;
        Ok(NetworkManager {
            package_id: ObjectID::ZERO, // TODO Revisit this when mainnet.
            client_address,
            sui_client,
        })
    }

    // Accessors
    pub fn get_client_address(&self) -> &SuiAddress {
        &self.client_address
    }
    pub fn get_package_id(&self) -> &ObjectID {
        &self.package_id
    }
    pub fn get_sui_client(&self) -> &SuiClient {
        &self.sui_client
    } // Needed?

    // Mutators
    pub fn set_package_id(&mut self, package_id: ObjectID) {
        self.package_id = package_id;
    }

    // Accessors that do a JSON-RPC call.
    pub async fn get_host_by_address(
        &self,
        host_address: SuiAddress,
    ) -> Result<HostInternal, anyhow::Error> {
        get_host_by_address(&self.sui_client, host_address).await
    }

    pub async fn get_localhost_by_address(
        &self,
        host_address: SuiAddress,
    ) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
        get_localhost_by_address(&self.sui_client, self.client_address, host_address).await
    }

    // Mutators that do a JSON-RPC call and transaction.
    pub async fn init_firewall(
        &self,
        localhost: &mut LocalhostInternal,
    ) -> Result<(), anyhow::Error> {
        // TODO Verify here client_address == localhost.admin_address
        // Detect user error.
        localhost.init_firewall(&self.sui_client).await
    }
}

/*
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn instantiate_network_manager() -> Result<(), anyhow::Error> {
        // TODO
        Ok(())
    }

    #[test]
    fn instantiate_hostinternal() -> Result<(), anyhow::Error> {
        // TODO
        Ok(())
    }

    #[test]
    fn instantiate_localhostinternal() -> Result<(), anyhow::Error> {
        // TODO
        Ok(())
    }
}*/
