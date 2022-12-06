use std::str::FromStr;
use sui_sdk::types::base_types::SuiAddress;
use sui_sdk::SuiClient;

use dtp_sdk::{ DTP, ConnectionApi, PeerNodeHandle, OwnNodeHandle };

#[tokio::main]
async fn main() -> Result<(), anyhow::Error>  {
    
    // Test localnet with the pre-funded wallet.
    let sui = SuiClient::new("http://0.0.0.0:9000", None, None).await?;
    let address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;
    let objects = sui.read_api().get_objects_owned_by_address(address).await?;
    println!("{:?}", objects);

    // Test that DTP SDK is properly linked, the code is mostly mocks for now.
    // TODO Figure out best way for user to use both SDKs at same time (same SuiClient?)
    let dtp: DTP = DTP::new()?;
    let con_api: &ConnectionApi = dtp.connection_api();

    let own_address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;
    let peer_address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;

    let peer_node: PeerNodeHandle = con_api.get_peer_node_by_address(peer_address).await?;
    let own_node: OwnNodeHandle = con_api.get_own_node_by_address(own_address).await?;

    println!("Ping result is {:?}", con_api.ping( &own_node, &peer_node ) );

    Ok(())
}
