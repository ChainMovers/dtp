// Structs commonly used between most files in this directory.

use derivative::Derivative;
use sui_keys::keystore::Keystore;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

#[derive(Derivative)]
#[derivative(Debug)]

// When a function requires SuiSDKParamsRPC you can
// assume that it will make a RPC call.
pub struct SuiSDKParamsRPC {
    pub client_address: SuiAddress,
    #[derivative(Debug = "ignore")]
    pub sui_client: Option<SuiClient>,
}

// When a function take SuiSDKParamsTxn you can
// assume there will be gas cost.
#[derive(Derivative)]
#[derivative(Debug)]
pub struct SuiSDKParamsTxn {
    pub package_id: ObjectID,
    #[derivative(Debug = "ignore")]
    pub keystore: Keystore,
}
