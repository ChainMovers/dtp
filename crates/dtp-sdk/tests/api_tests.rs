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

    // Check if localhost already exists, if yes, will skip first instantion test.
    let mut result = dtp.get_localhost().await.ok();

    if result.is_none() {
        // Check the API is consistent.
        assert_eq!(*dtp.localhost_id(), None);

        let new_localhost = dtp
            .create_localhost_on_network()
            .await
            .map_err(|e| e.context("Is the sui localnet process running on your machine?"))?;
        result = Some(new_localhost);
    }

    // Ownership from the creation that was just done.
    let localhost = result.expect("Creation of Localhost failed");
    let localhost_id = localhost.id();

    // The ids should all be visible and consistent through the API at this point.
    let api_dtp_localhost_id = dtp
        .localhost_id()
        .expect("Missing Localhost id at DTP level");

    let api_localhost = dtp
        .get_localhost()
        .await
        .expect("Localhost should exist at this point");

    let api_localhost_id = api_localhost.id();
    assert_eq!(*localhost_id, api_dtp_localhost_id);
    assert_eq!(api_localhost_id, localhost_id);

    Ok(())
}
