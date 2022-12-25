use dtp_sdk::DTP;
//use sui_sdk::types::base_types::{ObjectID, SuiAddress};
//use anyhow::anyhow;

use dtp_test_helper::{Sender, SuiNetworkForTest};
use serial_test::serial;
mod common;

#[tokio::test]
#[serial]
async fn localhost_instantiation_localnet() -> Result<(), anyhow::Error> {
    let network: SuiNetworkForTest = common::setup_localnet()?;

    let owner = network.get_sender_address(Sender::Test).clone();
    let mut dtp: DTP = DTP::new(owner, None).await?;
    dtp.add_rpc("http://0.0.0.0:9000", None, None).await?;
    dtp.set_package_id(network.dtp_package_id); // This won't be needed for mainnet.

    // Test API to create a Localhost.
    //
    // Localhost is an handle on a Sui shared object that can be
    // administrated only by this sender.
    let _localhost = dtp.create_localhost_on_network().await?;

    //assert!(network.object_exists(&localhost.get_object_id()).await?);

    Ok(())
}
