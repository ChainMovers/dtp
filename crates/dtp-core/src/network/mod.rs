use super::types::error::*;
use super::types::stats::*;

use std::path::PathBuf;
use std::time::Duration;
use sui_keys::keystore::{FileBasedKeystore, Keystore};
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

use anyhow::bail;

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

pub use self::transport_control_internal::*;

mod common_internal;
mod host_internal;

mod localhost_internal;

mod transport_control_internal;

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

    // Set once loaded from network (Registry)
    client_registry_id: Option<ObjectID>,
    localhost_id: Option<ObjectID>,
    volunteers_id: Vec<ObjectID>,

    // Set once loaded from network (Host object).
    localhost: Option<LocalhostInternal>,
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
            client_registry_id: None,
            localhost_id: None,
            volunteers_id: Vec::new(),
            localhost: None,
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
    pub fn get_localhost_id(&self) -> &Option<ObjectID> {
        &self.localhost_id
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
    pub async fn get_host(&self, host_id: ObjectID) -> Result<HostInternal, anyhow::Error> {
        get_host_by_id(&self.sui_sdk_params.rpc, host_id).await
    }

    /*
    async fn get_objects_owned(&mut self) -> Result<(), anyhow::Error> {
        let sui_client = self.get_sui_client()?;

        let net_resp = sui_client
            .read_api()
            .get_objects_owned_by_address(*self.get_client_address())
            .await
            .map_err(|e| DTPError::FailedRPCGetObjectsOwnedByClientAddress {
                client: self.get_client_address().to_string(),
                inner: e.to_string(),
            })?;
        /*
        for v in net_resp.iter() {

        }*/

        Ok(())
    }*/

    async fn get_localhost_id_from_registry(&mut self) -> Result<ObjectID, anyhow::Error> {
        Err(DTPError::NotImplemented.into())
    }

    pub async fn get_localhost(&mut self) -> Result<LocalhostInternal, anyhow::Error> {
        // Get the id if already local.
        //
        // If not local, retreive all objects and select the
        // valid localhost.
        //
        let localhost_id = match self.localhost_id {
            Some(x) => x,
            None => self.get_localhost_id_from_registry().await?,
        };
        //get_localhost_by_id(&self.sui_sdk_params.rpc, localhost_id).await;
        // Update localhost object
        get_localhost_by_id(&self.sui_sdk_params.rpc, localhost_id).await
    }

    pub async fn load_local_client_registry(
        &mut self,
    ) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
        Err(DTPError::NotImplemented.into())
    }

    // Mutators that do a JSON-RPC call and transaction.
    pub async fn init_firewall(&self) -> Result<(), anyhow::Error> {
        // TODO Verify here client_address == localhost.admin_address
        // Detect user error.
        Ok(())
    }

    pub async fn create_localhost_on_network(&mut self) -> Result<HostInternal, anyhow::Error> {
        // This function clear all local state and check if a
        // Localhost instance already exists on the network.
        //
        // If there is already one, then it will be reflected in the
        // local state and Err(DTPAlreadyExist) will be returned.
        //
        // If None are found on the network, a new Localhost will
        // tentatively be created.
        self.localhost_id = None;
        self.client_registry_id = None;

        // Do a RPC call to get the on-chain state of the registry.
        // If there is no registry, then assume there is no localhost.
        // Both will be created in a single transaction later (to
        // minimize cost and race conditions possibility).
        let _ = self.load_local_client_registry().await;

        // A Localhost is already on the network.
        if let Some(x) = self.localhost_id {
            return Err((DTPError::DTPLocalhostAlreadyExists {
                localhost: x.to_string(),
                client: self.get_client_address().to_string(),
            })
            .into());
        }

        // Proceed with the creation.
        // TODO Retry once in a controlled manner?
        let localhost =
            create_localhost_on_network(&self.sui_sdk_params.rpc, &self.sui_sdk_params.txn).await?;

        let localhost_id = localhost.object_id(); // Copy for later

        self.localhost_id = Some(localhost.object_id());
        self.localhost = Some(localhost);

        // Creation succeeded.
        //
        // Double check to minimise caller having to deal with "race condition". Do a RPC to
        // the fullnode to verify if it reflects the creation. Keep trying for up to 10 seconds.
        //
        // Holding the end-user is not ideal, but will minimize a lot of "user complain" of
        // temporary error that are not really error. Have to give the slowest fullnodes a chance
        // to reflect the network changes.

        // TODO Must be a more robust retry ... no bail on network failure here...
        // self.ensure_localhost_ready().await?;

        // Create a Host for the API user with only the ObjectID set.
        // The API can "catch it" as the localhost and give it special handling.
        Ok(HostInternal {
            object_id: localhost_id,
            admin_address: None,
            raw: None,
        })
    }

    pub async fn ensure_localhost_ready(&mut self) -> Result<(), anyhow::Error> {
        // Most of the time this function will not detect any problem and quickly return Ok.
        //
        // In rare occasion, may detect that a corner case or network disruption may have left
        // things in an unusual state, and some additional RPC might be attempted to recover
        // or return an error for allowing the caller to take action.
        //
        // This function will never cause additional Sui gas expense.
        if self.get_localhost_id().is_none() {
            bail!(DTPError::DTPLocalhostDoesNotExists)
        }

        // Verify that the localhost (Host object) is known, if not, then
        // try to recover by retreiving it now.
        //
        // This might have happen if this is the very first time the user
        // is using DTP and have just created the Localhost object on the Sui
        // network (so its object id is known upon creation) but have never
        // use it yet (so the object fields were never retreived!).
        if self.localhost.is_none() {
            // Load the Move Host object corresponding to the Localhost.
            self.get_localhost().await?;
            // Test again. Must work this time.
            if self.localhost.is_none() {
                bail!(DTPError::DTPLocalhostDataMissing)
            }
        }

        Ok(())
    }

    pub async fn ping_on_network(
        &mut self,
        target_host: &HostInternal,
    ) -> Result<PingStats, anyhow::Error> {
        self.ensure_localhost_ready().await?;

        // unwrap() will not fail because ensure_localhost_ready()
        let localhost = self.localhost.as_ref().unwrap();

        // Create connection.
        let mut _tci = create_best_effort_transport_control_on_network(
            &self.sui_sdk_params.rpc,
            &self.sui_sdk_params.txn,
            localhost,
            target_host,
            0,
            Some(0),
            Some(0),
        )
        .await?;

        let stats = PingStats {
            ping_count_attempted: 1,
            ..Default::default()
        };

        Ok(stats)
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
