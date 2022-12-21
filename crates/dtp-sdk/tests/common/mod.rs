// Function to facilitate interacting with a localnet.
//
// Will verify:
//    - Sui binary is installed.
//    - sui process is running for localnet (devnet branch).
//    - Latest Move file changes are compiled and publish on localnet.
//
// Can safely be called even if everything has already been setup.
//
//
use anyhow;
use dtp_test_helper::SuiNetworkForTest;
//use sui_sdk::types::base_types::{ObjectID, SuiAddress};

pub fn setup_localnet() -> Result<SuiNetworkForTest, anyhow::Error> {
    let network = SuiNetworkForTest::new()?;
    Ok(network)
}
