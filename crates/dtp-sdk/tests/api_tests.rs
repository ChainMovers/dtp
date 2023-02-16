use dtp_sdk::{Host, DTP};
//use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use anyhow::Result;

use dtp_test_helper::{Sender, SuiNetworkForTest};
use serial_test::serial;
mod common;

#[allow(dead_code)]
struct TwoHostsSetup {
    pub network: SuiNetworkForTest,
    pub dtp: DTP,
    pub dtp_peer: DTP,
    pub localhost: Host,
    pub host: Host,
}

// This is a series of objects that are assumed to be always present
// for a single bi-directional connection.
async fn create_two_hosts_setup() -> Result<TwoHostsSetup, anyhow::Error> {
    let network: SuiNetworkForTest = common::setup_localnet()?;

    let owner = network.get_sender_address(Sender::LocalClient).clone();
    let mut dtp: DTP = DTP::new(owner, None).await?;
    dtp.add_rpc_url("http://0.0.0.0:9000").await?;
    dtp.set_package_id(network.dtp_package_id); // This won't be needed for mainnet.

    // Create and test a localhost.
    let mut result = dtp.get_host().await.ok();

    if result.is_none() {
        // Check the API is consistent.
        assert_eq!(*dtp.localhost_id(), None);

        let new_localhost = dtp
            .create_host_on_network()
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
        .get_host()
        .await
        .expect("Localhost should exist at this point");

    let api_localhost_id = api_localhost.id();
    assert_eq!(*localhost_id, api_dtp_localhost_id);
    assert_eq!(api_localhost_id, localhost_id);

    // Create the second host.
    let second_owner = network.get_sender_address(Sender::PeerServer).clone();
    let mut dtp2: DTP = DTP::new(second_owner, None).await?;
    dtp2.add_rpc_url("http://0.0.0.0:9000").await?;
    dtp2.set_package_id(network.dtp_package_id); // This won't be needed for mainnet.

    let mut result2 = dtp2.get_host().await.ok();

    if result2.is_none() {
        // Check the API is consistent.
        assert_eq!(*dtp2.localhost_id(), None);

        let new_localhost2 = dtp2
            .create_host_on_network()
            .await
            .map_err(|e| e.context("Is the sui localnet process running on your machine?"))?;
        result2 = Some(new_localhost2);
    }
    // Ownership from the creation that was just done.
    let localhost2 = result2.expect("Creation of second Localhost failed");
    let host2_id = localhost2.id();

    // Now test doing a get_Host of these host ids using both clients.
    let host = dtp.get_host_by_id(*host2_id).await?;

    Ok(TwoHostsSetup {
        network,
        dtp,
        dtp_peer: dtp2,
        localhost,
        host,
    })
}

#[tokio::test]
#[serial]
async fn integration_localnet() -> Result<(), anyhow::Error> {
    #[allow(dead_code)]
    let mut two_hosts = create_two_hosts_setup().await?;
    #[allow(dead_code)]
    let _ping_result = two_hosts.dtp.ping_on_network(&two_hosts.host).await?;

    Ok(())
}
