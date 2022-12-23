use super::common_internal::*;
use anyhow::bail;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};

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
pub struct HostInternal {
    sui_id: ObjectID,
}

pub(crate) async fn get_host_by_address(
    rpc: &SuiSDKParamsRPC,
    host_address: SuiAddress,
) -> Result<HostInternal, anyhow::Error> {
    let sui_id = ObjectID::from(host_address);

    let sui_client = rpc.sui_client.as_ref().expect("Could not create SuiClient");
    let net_resp = sui_client
        .read_api()
        .get_parsed_object(sui_id)
        .await
        .unwrap();

    let object = net_resp.object()?;

    // Sanity test that the id is as expected.
    if object.id() != sui_id {
        bail!("Bad object id {} != {}", object.id(), sui_id);
    }

    // TODO Validate the object type, get the services provided etc...

    // Success. Host Move object transformed into a convenient local Host handle.
    let ret = HostInternal { sui_id };
    Ok(ret)
}

impl HostInternal {
    pub(crate) fn new(sui_id: ObjectID) -> HostInternal {
        HostInternal { sui_id }
    }
    pub fn get_sui_id(&self) -> &ObjectID {
        &self.sui_id
    }
}
