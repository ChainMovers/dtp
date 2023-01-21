use super::super::types::error::*;
use super::host_internal::HostInternal;
use super::{common_internal::*, LocalhostInternal};

// Stuff needed typically for a Move Call
use std::str::FromStr;
use sui_keys::keystore::AccountKeystore;
use sui_sdk::json::SuiJsonValue;
use sui_sdk::types::base_types::ObjectID;
use sui_sdk::types::messages::Transaction;
use sui_types::intent::Intent;
use sui_types::messages::ExecuteTransactionRequestType;

use anyhow::bail;

// The "internal" object is a private implementation (not intended to be
// directly exposed throught the DTP SDK).
pub struct TransportControlInternal {
    // Set when TC confirmed exists.
    package_id: Option<ObjectID>,
    object_id: Option<ObjectID>,

    // Parameters used when the object was built (only set
    // if was part of a recent operation).
    call_args: Option<Vec<SuiJsonValue>>,
}

pub(crate) async fn create_best_effort_transport_control_on_network(
    rpc: &SuiSDKParamsRPC,
    txn: &SuiSDKParamsTxn,
    localhost: &LocalhostInternal,
    server_host: &HostInternal,
    _server_protocol: u16,
    _server_port: Option<u16>,
    _return_port: Option<u16>,
) -> Result<TransportControlInternal, anyhow::Error> {
    let sui_client = match rpc.sui_client.as_ref() {
        Some(x) => x,
        None => bail!(DTPError::DTPMissingSuiClient),
    };

    let server_adm = match server_host.admin_address() {
        Some(x) => x,
        None => bail!(DTPError::DTPMissingServerAdminAddress),
    };

    /* Params must match. See tranport_control.move
       client_host: ID,
       server_host: ID,
       server_adm: address,
       protocol: u16,
       port: u16,
       return_port: u16,
    */

    let call_args = vec![
        SuiJsonValue::from_object_id(localhost.object_id()),
        SuiJsonValue::from_object_id(server_host.object_id()),
        SuiJsonValue::from_str(&server_adm.to_string()).unwrap(),
        SuiJsonValue::from_str("0").unwrap(),
        SuiJsonValue::from_str("0").unwrap(),
        SuiJsonValue::from_str("0").unwrap(),
    ];

    let move_call = sui_client
        .transaction_builder()
        .move_call(
            rpc.client_address,
            txn.package_id,
            "transport_control",
            "create_best_effort",
            vec![],
            call_args,
            None, // The node will pick a gas object belong to the signer if not provided.
            1000,
        )
        .await
        .map_err(|e| DTPError::FailedMoveHostCreate {
            client: rpc.client_address.to_string(),
            inner: e.to_string(),
        })?;

    // Sign transaction.
    let signature = txn
        .keystore
        .sign_secure(&rpc.client_address, &move_call, Intent::default())?;

    let response = sui_client
        .quorum_driver()
        .execute_transaction(
            Transaction::from_data(move_call, Intent::default(), signature).verify()?,
            Some(ExecuteTransactionRequestType::WaitForLocalExecution),
        )
        .await?;

    // Get the id from the newly created Sui object.

    let _sui_id = response
        .effects
        .unwrap()
        .created
        .first()
        .unwrap()
        .reference
        .object_id;

    assert!(response.confirmed_local_execution);

    // All good. Build the DTP handles.
    let tci = TransportControlInternal {
        package_id: None,
        object_id: None,
        call_args: None,
    };
    Ok(tci)
}
