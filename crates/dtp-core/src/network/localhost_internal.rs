use super::host_internal::*;
use sui_sdk::types::base_types::SuiAddress;
use sui_sdk::SuiClient;
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

pub(crate) async fn get_localhost_by_address(
    sui_client: &SuiClient,
    client_address: SuiAddress,
    host_address: SuiAddress,
) -> Result<(HostInternal, LocalhostInternal), anyhow::Error> {
    // Do the equivalent of get_host_by_address, but
    // create a handle that will allow for administrator
    // capabilities.
    #[allow(clippy::needless_borrow)]
    let host_internal =
        super::host_internal::get_host_by_address(&sui_client, host_address).await?;

    let localhost_internal = LocalhostInternal {
        admin_address: client_address,
        firewall_initialized: false,
    };

    Ok((host_internal, localhost_internal))
}

impl LocalhostInternal {
    pub fn get_admin_address(&self) -> &SuiAddress {
        &self.admin_address
    }

    pub(crate) async fn init_firewall(
        &mut self,
        _sui_client: &SuiClient,
    ) -> Result<(), anyhow::Error> {
        // Dummy mutable for now... just to test the software design "layering"
        // with a mut.
        self.firewall_initialized = true;
        Ok(())
    }
}
