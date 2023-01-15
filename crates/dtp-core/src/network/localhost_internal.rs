use super::super::types::error::*;
use super::common_internal::*;
use super::host_internal::*;

//use std::str::FromStr;
use sui_keys::keystore::AccountKeystore;
//use sui_sdk::json::SuiJsonValue;
use sui_adapter::execution_mode;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::types::messages::Transaction;
use sui_types::intent::Intent;
use sui_types::messages::ExecuteTransactionRequestType;

/*
use sui_json_rpc_types::{
    EventPage, MoveCallParams, OwnedObjectRef, RPCTransactionRequestParams,
    SuiCertifiedTransaction, SuiData, SuiEvent, SuiEventEnvelope, SuiExecutionStatus,
    SuiGasCostSummary, SuiObject, SuiObjectInfo, SuiObjectRead, SuiObjectRef, SuiParsedData,
    SuiPastObjectRead, SuiRawData, SuiRawMoveObject, SuiTransactionAuthSignersResponse,
    SuiTransactionData, SuiTransactionEffects, SuiTransactionResponse, TransactionBytes,
    TransactionsPage, TransferObjectParams,
};*/

#[derive(Debug)]
pub struct LocalhostInternal {
    admin_address: SuiAddress,
    firewall_initialized: bool,
}

pub(crate) async fn get_localhost_by_id(
    rpc: &SuiSDKParamsRPC,
    host_id: ObjectID,
) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
    // Do the equivalent of get_host_by_id, but
    // create a handle that will allow for administrator
    // capabilities.
    #[allow(clippy::needless_borrow)]
    let host_internal = super::host_internal::get_host_by_id(rpc, host_id).await?;

    let localhost_internal = LocalhostInternal {
        admin_address: rpc.client_address,
        firewall_initialized: false,
    };

    Ok((host_internal, localhost_internal))
}

pub(crate) async fn create_localhost_on_network(
    rpc: &SuiSDKParamsRPC,
    txn: &SuiSDKParamsTxn,
) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
    // Do not allow to create a new one if one already exists
    // for this user.

    // TODO: Remove panic.
    let sui_client = rpc.sui_client.as_ref().expect("Could not create SuiClient");

    let create_host_call = sui_client
        .transaction_builder()
        .move_call::<execution_mode::Normal>(
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
    let sui_id = response
        .effects
        .unwrap()
        .created
        .first()
        .unwrap()
        .reference
        .object_id;

    assert!(response.confirmed_local_execution);

    // All good. Build the DTP handles.
    Ok((
        HostInternal::new(sui_id),
        LocalhostInternal {
            admin_address: rpc.client_address,
            firewall_initialized: false,
        },
    ))
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
}
