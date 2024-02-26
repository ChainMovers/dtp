// What is the type naming convention?
//
// "Object"         --> Name of the object in the move package
//
// "ObjectInternal" --> Local memory representation, may have additional
//                      fields not found on the network.
//
// "ObjectMoveRaw" --> Serialized fields as intended to be for the network
//                     *MUST* match the Move Sui definition of a given version.
//
// Example:
//   "Host"
//   "HostInternal"
//   "HostMoveRaw"
//
use super::common_internal::*;

use serde::Deserialize;
use sui_json_rpc_types::SuiData;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_types::id::UID;

// Data structure that **must** match the Move Host object
#[derive(Deserialize, Debug)]
pub struct HostMoveRaw {
    id: UID,
    flgs: u8,
    adm: SuiAddress,
    conn_req: u64,
    conn_sdd: u64,
    conn_del: u64,
    conn_rcy: u64,
    max_con: u16,
}

#[derive(Debug)]
pub struct HostInternal {
    pub(crate) object_id: ObjectID,
    pub(crate) admin_address: Option<SuiAddress>,
    pub(crate) raw: Option<HostMoveRaw>, // Data from network (as-is)
}

pub(crate) async fn fetch_move_host_object(
    rpc: &SuiSDKParamsRPC,
    host_object_id: ObjectID,
) -> Result<HostMoveRaw, anyhow::Error> {
    // TODO Revisit that for robustness
    let sui_client = rpc.sui_client.as_ref().expect("Could not create SuiClient");
    let raw_obj = sui_client.read_api().get_object(host_object_id).await?;
    raw_obj.object()?.data.try_as_move().unwrap().deserialize()
}

pub(crate) async fn get_host_by_id(
    rpc: &SuiSDKParamsRPC,
    host_object_id: ObjectID,
) -> Result<HostInternal, anyhow::Error> {
    let raw = fetch_move_host_object(rpc, host_object_id).await?;

    // Map the Host Move object into the local memory representation.
    let ret = HostInternal {
        object_id: host_object_id,
        admin_address: Some(raw.adm),
        raw: Some(raw),
    };
    Ok(ret)
}

impl HostInternal {
    pub(crate) fn new(object_id: ObjectID) -> HostInternal {
        HostInternal {
            object_id,
            admin_address: None,
            raw: None,
        }
    }

    pub fn object_id(&self) -> ObjectID {
        self.object_id
    }

    pub fn admin_address(&self) -> Option<SuiAddress> {
        self.admin_address
    }
}
