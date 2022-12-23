use std::path::PathBuf;
use sui_keys::keystore::{FileBasedKeystore, Keystore};
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;
use tokio::time::Duration;

// Flatten many sub modules/files under the same dtp_core::network module.
//
// Allows to do:
//    use dtp_core::network::{NetworkManager, HostInternal, LocalhostInternal}
//
// Instead of verbose:
//    use dtp_core::network::NetworkManager;
//    use dtp_core::network::host_internal::HostInternal;
//    use dtp_core::network::localhost_internal::LocalhostInternal;
pub use self::common_internal::*;
pub use self::host_internal::*;
pub use self::localhost_internal::*;

mod common_internal;
mod host_internal;
mod localhost_internal;

// The default location for localnet is relative to
// this module Cargo.toml location.
//
// TODO Handle default for devnet/testnet ... mainnet.
const DEFAULT_LOCALNET_KEYSTORE_PATHNAME: &str = "../../../dtp-dev/localnet/sui.keystore";

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

#[allow(dead_code)]
pub struct NetworkManager {
    sui_sdk_params: SuiSDKParams,
    localhost_id: Option<ObjectID>,
    volunteers_id: Vec<ObjectID>,
}

impl NetworkManager {
    pub async fn new(
        client_address: SuiAddress,
        keystore_pathname: Option<&str>,
    ) -> Result<Self, anyhow::Error> {
        // TODO Rewrite the building of the PathBuf for devnet/testnet... mainnet.
        let pathbuf = if let Some(x) = keystore_pathname {
            PathBuf::from(x)
        } else {
            let path = env!("CARGO_MANIFEST_DIR");
            let pathname = format!("{}/{}", path, DEFAULT_LOCALNET_KEYSTORE_PATHNAME);
            PathBuf::from(pathname)
        };

        let keystore = Keystore::File(FileBasedKeystore::new(&pathbuf)?);
        Ok(NetworkManager {
            sui_sdk_params: SuiSDKParams {
                rpc: SuiSDKParamsRPC {
                    client_address,
                    sui_client: None,
                },
                txn: SuiSDKParamsTxn {
                    package_id: ObjectID::ZERO, // TODO Revisit this when mainnet.
                    keystore,
                },
            },
            localhost_id: None,
            volunteers_id: Vec::new(),
        })
    }

    // Add RPC details. For now, allow only one to be added.
    pub async fn add_rpc(
        &mut self,
        http_url: &str,
        ws_url: Option<&str>,
        request_timeout: Option<Duration>,
    ) -> Result<(), anyhow::Error> {
        let sui_client = SuiClient::new(http_url, ws_url, request_timeout).await?;
        self.sui_sdk_params.rpc.sui_client = Some(sui_client);
        Ok(())
    }

    // Accessors
    pub fn get_client_address(&self) -> &SuiAddress {
        &self.sui_sdk_params.rpc.client_address
    }
    pub fn get_package_id(&self) -> &ObjectID {
        &self.sui_sdk_params.txn.package_id
    }

    pub fn get_sui_client(&self) -> Result<&SuiClient, anyhow::Error> {
        Ok(self
            .sui_sdk_params
            .rpc
            .sui_client
            .as_ref()
            .expect("Cannot get SuiClient"))
    } // Needed?

    // Mutators
    pub fn set_package_id(&mut self, package_id: ObjectID) {
        self.sui_sdk_params.txn.package_id = package_id;
    }

    // Accessors that do a JSON-RPC call.
    pub async fn get_host_by_address(
        &self,
        host_address: SuiAddress,
    ) -> Result<HostInternal, anyhow::Error> {
        get_host_by_address(&self.sui_sdk_params.rpc, host_address).await
    }

    pub async fn get_localhost_by_address(
        &self,
        host_address: SuiAddress,
    ) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
        get_localhost_by_address(&self.sui_sdk_params.rpc, host_address).await
    }

    // Mutators that do a JSON-RPC call and transaction.
    pub async fn init_firewall(
        &self,
        localhost: &mut LocalhostInternal,
    ) -> Result<(), anyhow::Error> {
        // TODO Verify here client_address == localhost.admin_address
        // Detect user error.
        localhost
            .init_firewall(&self.sui_sdk_params.rpc, &self.sui_sdk_params.txn)
            .await
    }

    pub async fn create_localhost_on_network(
        &self,
    ) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
        let (host, localhost) =
            create_localhost_on_network(&self.sui_sdk_params.rpc, &self.sui_sdk_params.txn).await?;

        // To minimise caller having to deal with "race condition", do a RPC to the fullnode
        // to verify if it reflects the creation. Keep trying for up to 5 seconds.
        //
        // Do not fail this call if the fullnode is somehow too slow. The creation has already
        // succeeded from the point of view of the transaction effects.
        //
        Ok((host, localhost))
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
