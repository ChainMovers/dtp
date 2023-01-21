use super::super::types::error::*;
use super::common_internal::*;
use super::host_internal::*;

use sui_keys::keystore::AccountKeystore;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::types::messages::Transaction;
use sui_types::intent::Intent;
use sui_types::messages::ExecuteTransactionRequestType;

#[derive(Debug)]
pub struct LocalhostInternal {
    #[allow(dead_code)]
    object_id: ObjectID,
    admin_address: SuiAddress,
    #[allow(dead_code)]
    firewall_initialized: bool,
    #[allow(dead_code)]
    host_internal: HostInternal,
}

pub(crate) async fn get_localhost_by_id(
    rpc: &SuiSDKParamsRPC,
    host_id: ObjectID,
) -> Result<LocalhostInternal, anyhow::Error> {
    // Do the equivalent of get_host_by_id, but
    // create a handle that will allow for administrator
    // capabilities.
    #[allow(clippy::needless_borrow)]
    let host_internal = super::host_internal::get_host_by_id(rpc, host_id).await?;

    let localhost_internal = LocalhostInternal {
        object_id: host_id,
        admin_address: rpc.client_address,
        firewall_initialized: false,
        host_internal,
    };

    Ok(localhost_internal)
}

pub(crate) async fn create_localhost_on_network(
    rpc: &SuiSDKParamsRPC,
    txn: &SuiSDKParamsTxn,
) -> Result<LocalhostInternal, anyhow::Error> {
    // Do not allow to create a new one if one already exists
    // for this user.

    // TODO: Remove panic.
    let sui_client = rpc.sui_client.as_ref().expect("Could not create SuiClient");

    let create_host_call = sui_client
        .transaction_builder()
        .move_call(
            rpc.client_address,
            txn.package_id,
            "host",
            "create",
            vec![],
            vec![],
            None, // The node will pick a gas object belong to the signer if not provided.
            1000,
        )
        .await
        .map_err(|e| DTPError::FailedMoveHostCreate {
            client: rpc.client_address.to_string(),
            inner: e.to_string(),
        })?;

    // Sign transaction.
    let signature =
        txn.keystore
            .sign_secure(&rpc.client_address, &create_host_call, Intent::default())?;

    let response = sui_client
        .quorum_driver()
        .execute_transaction(
            Transaction::from_data(create_host_call, Intent::default(), signature).verify()?,
            Some(ExecuteTransactionRequestType::WaitForLocalExecution),
        )
        .await?;

    // Get the id from the newly created Sui object.
    let object_id = response
        .effects
        .unwrap()
        .created
        .first()
        .unwrap()
        .reference
        .object_id;

    assert!(response.confirmed_local_execution);

    // Success.
    Ok(LocalhostInternal {
        object_id,
        admin_address: rpc.client_address,
        firewall_initialized: false,
        host_internal: HostInternal::new(object_id),
    })
}

impl LocalhostInternal {
    pub fn get_admin_address(&self) -> &SuiAddress {
        &self.admin_address
    }

    pub(crate) async fn init_firewall(
        &mut self,
        _rpc: &SuiSDKParamsRPC,
        _txn: &SuiSDKParamsTxn,
    ) -> Result<(), anyhow::Error> {
        // Dummy mutable for now... just to test the software design "layering"
        // with a mut.
        self.firewall_initialized = true;
        Ok(())
    }

    pub fn object_id(&self) -> ObjectID {
        self.object_id
    }
}
