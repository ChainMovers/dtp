use dtp_sdk::{ConnectionApi, DTP};
use serial_test::serial;

#[tokio::test]
#[serial]
async fn localhost_instantiation_localnet() -> Result<(), anyhow::Error> {
    let dtp: DTP = DTP::new("http://0.0.0.0:9000", None).await?;
    let _con_api: &ConnectionApi = dtp.connection_api();
    Ok(())
}
