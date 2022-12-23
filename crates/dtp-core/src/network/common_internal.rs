// Structs commonly used between most files in this directory.
// Must remain public because used within the public NetworkManager struct.

// When a function take this as parameter, you can assume
// there is no gas cost.
use derivative::Derivative;
use sui_keys::keystore::Keystore;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

#[derive(Derivative)]
#[derivative(Debug)]

// When a function take SuiSDKParamsRPC as parameter, you can
// assume that it will make a RPC call.
pub struct SuiSDKParamsRPC {
    pub client_address: SuiAddress,
    #[derivative(Debug = "ignore")]
    pub sui_client: Option<SuiClient>,
}

// When a function take SuiSDKParamsTxn as parameter, you can
// assume a Sui transaction will be attempted and there
// will be gas cost.
#[derive(Derivative)]
#[derivative(Debug)]
pub struct SuiSDKParamsTxn {
    pub package_id: ObjectID,
    #[derivative(Debug = "ignore")]
    pub keystore: Keystore,
}

#[derive(Debug)]
pub struct SuiSDKParams {
    pub rpc: SuiSDKParamsRPC,
    pub txn: SuiSDKParamsTxn,
}
