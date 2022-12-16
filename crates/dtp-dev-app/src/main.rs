use std::str::FromStr;
use sui_sdk::types::base_types::SuiAddress;
use sui_sdk::SuiClient;

use dtp_sdk::{ConnectionApi, Host, Localhost, DTP};

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // Test localnet with the pre-funded wallet.
    let sui = SuiClient::new("http://0.0.0.0:9000", None, None).await?;
    let address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;
    let objects = sui.read_api().get_objects_owned_by_address(address).await?;
    println!("{:?}", objects);

    let own_address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;

    let dtp: DTP = DTP::new("http://0.0.0.0:9000", None).await?;
    let con_api: &ConnectionApi = dtp.connection_api();

    let peer_address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;

    let peer_node: Host = con_api.get_host_by_address(peer_address).await?;
    let own_node: Localhost = con_api
        .get_localhost_by_address(own_address, own_address)
        .await?;

    println!("Ping result is {:?}", con_api.ping(&own_node, &peer_node));

    Ok(())
}
