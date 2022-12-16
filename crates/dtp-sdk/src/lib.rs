// For now, just focusing on getting the SDKs dependencies right, code is meaningless.
use std::str::FromStr;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

// High-Level Design (very rough for now, likely to evolve):
//
//    - Create a DTPClient for every committe intended to be used.
//
//    - Use a DTPClient to access its various APIs e.g. dtp_client.connection_api()
//
//    - A Shared Object on the Sui network can have one or more local handles.
//
//      Example: connection_api.get_peer_node_by_address() creates a local
//               handle of an existing Sui Node Shared Object that belongs
//               to someone else.
//
//      When an handle is created it copies a subset of fields from the network object.
//
//      These fields can change only when the handle update() method is successfully
//      called.
//
//      Since the same network object can have multiple handles, it is possible
//      to, as an example, identify change in a field using two handles.

#[derive(Debug)]
#[allow(dead_code)]
pub struct Host {
    sui_id: ObjectID,
}

// Similar to Host, but with additional functionality available
// assuming you are the administrator of the Host.
#[allow(dead_code)]
pub struct Localhost {
    host: Host,
}

// Provides all the DTP SDK APIs.
#[allow(dead_code)]
pub struct DTP {
    connection_api: ConnectionApi,
    sui_client: SuiClient,
}

impl DTP {
    pub async fn new(http_url: &str, ws_url: Option<&str>) -> Result<Self, anyhow::Error> {
        let connection_api = ConnectionApi;

        // TODO Revisit if should be done here or caller should own it...
        let sui_client = SuiClient::new(http_url, ws_url, None).await?;

        Ok(DTP {
            connection_api,
            sui_client,
        })
    }

    pub fn connection_api(&self) -> &ConnectionApi {
        &self.connection_api
    }

    pub fn sui_client(&self) -> &SuiClient {
        &self.sui_client
    }
}
pub struct ConnectionApi;

impl ConnectionApi {
    // Get an handle of any DTP Host expected to be already on the Sui network.
    //
    // The handle is used for doing operations such as ping the host and create connections.
    pub async fn get_host_by_address(
        &self,
        _host_address: SuiAddress,
    ) -> Result<Host, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        Ok(Host {
            sui_id: ObjectID::from_str("0x6205fc058b205227d7b7bd5b4e7802f0055157c6")?,
        })
    }

    // Get an handle of a DTP Host that your application controls.
    //
    // It is expected that the host already exist on the network, if not,
    // then see create_localhost().
    //
    pub async fn get_localhost_by_address(
        &self,
        localhost_address: SuiAddress, // Address of the targeted localhost.
        _admin_address: SuiAddress,    // Administrator address for the localhost.
    ) -> Result<Localhost, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        let host = self.get_host_by_address(localhost_address).await?;
        Ok(Localhost { host })
    }

    // Create a new DTP Host on the Sui network.
    //
    // The host object created on the network will be retreiveable
    // as a DTP::Host handle for everyone (see get_host_XXXX).
    //
    // For the administrator the same object can also be retreiveable
    // as a DTP::Localhost handle (see get_localhost_xxxx).
    //
    // The administrator is the only one allowed to configure the
    // host object on the network using the Localhost handle.
    pub async fn create_host_on_network(&self) -> Result<Localhost, anyhow::Error> {
        // TODO Mocking for now, but calling into Sui SDK for conversion.
        Ok(Localhost {
            host: Host {
                sui_id: ObjectID::from_str("0x6205fc058b205227d7b7bd5b4e7802f0055157c6")?,
            },
        })
    }

    pub fn ping(&self, _own_node: &Localhost, _peer_node: &Host) -> Result<bool, anyhow::Error> {
        Ok(true)
    }
}

// The API requires both localnet/devnet access. See dtp-sdk/tests for API integration tests.
