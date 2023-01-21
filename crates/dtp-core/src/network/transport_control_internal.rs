use super::super::types::error::*;
use super::common_internal::*;

// Stuff needed typically for for a Move Call
use sui_adapter::execution_mode;
use sui_keys::keystore::AccountKeystore;
use sui_sdk::json::SuiJsonValue;
use sui_sdk::types::base_types::ObjectID;
use sui_sdk::types::messages::Transaction;
use sui_types::intent::Intent;
use sui_types::messages::ExecuteTransactionRequestType;

// The "internal" object is a private implementation (not intended to be
// directly exposed throught the DTP SDK).
pub struct TransportControlInternal {
    // Set when TC confirmed exists.
    #[allow(dead_code)]
    package_id: Option<ObjectID>,
    #[allow(dead_code)]
    object_id: Option<ObjectID>,

    // Parameters used when the object was built (only set
    // if was part of a recent operation).
    #[allow(dead_code)]
    call_args: Option<Vec<SuiJsonValue>>,
}

#[allow(dead_code)]
pub(crate) async fn create_best_effort_transport_control_on_network(
    rpc: &SuiSDKParamsRPC,
    txn: &SuiSDKParamsTxn,
) -> Result<TransportControlInternal, anyhow::Error> {
    // TODO: Remove panic.
    let sui_client = rpc.sui_client.as_ref().expect("Could not create SuiClient");

    /* Params must match. See tranport_control.move
        client_host: Option<ID>,
        server_host: ID,
        client_authority: Option<address>,
        server_admin: address,
        client_tx_pipe: Option<ID>,
        server_tx_pipe: Option<ID>,
        protocol: u16,
        port: Option<u16>,
        return_port: Option<u16>
    */
    let call_args = vec![];

    let move_call = sui_client
        .transaction_builder()
        .move_call::<execution_mode::Normal>(
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
