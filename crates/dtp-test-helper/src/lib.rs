// Access to the following information:
//  - ObjectID of the last DTP Move Package that was published on localnet.
//  - Various client_address with gas coins on that localnet.
//
// This module does not mutate the localnet (all read-only).
//
// Note: It is assumed that localnet is running and DTP modules were
//       published to it. if not, then run "dtp/script/publish-localnet".
use std::fs::{self, File};
use std::io::{self, BufRead};
use std::path::Path;
use std::str::FromStr;

use anyhow::Result;
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use sui_sdk::SuiClient;

#[allow(dead_code)]

// localnet provides 5 sender addresses with funds.
//
// These addresses are "reserved" in a way that various process
// won't interfere with each other.
//
// Use get_sender_address() for access.
pub enum Sender {
    Test = 0,        // Local client for dtp-sdk integration tests.
    LocalClient = 1, // Local client for development.
    LocalServer = 2, // Local dtp-server for development.
    PeerClient = 3,  // Simulated remote client (peer).
    PeerServer = 4,  // Simulated remote dtp-server (peer).
}

pub struct SuiNetworkForTest {
    pub dtp_package_id: ObjectID, // Last package that was published.

    sender_addresses: Vec<SuiAddress>,
}

impl SuiNetworkForTest {
    fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
    where
        P: AsRef<Path>,
    {
        let file = File::open(filename)?;
        Ok(io::BufReader::new(file).lines())
    }

    fn trim_newline(s: &mut String) {
        if s.ends_with('\n') {
            s.pop();
            if s.ends_with('\r') {
                s.pop();
            }
        }
    }

    pub fn new() -> Result<SuiNetworkForTest, anyhow::Error> {
        // Get the pre-funded clients from client_addresses.txt
        let path = env!("CARGO_MANIFEST_DIR");
        let pathname = format!(
            "{}{}",
            path, "/../../../dtp-dev/publish_data/localnet/package_id.txt"
        );

        // Get the DTP package id from when it was last published.
        let mut package_id_hex = fs::read_to_string(&pathname)?;
        SuiNetworkForTest::trim_newline(&mut package_id_hex);

        let dtp_package_id = ObjectID::from_hex_literal(&package_id_hex)?;
        // TODO .with_context(|| format!("Failed to parse package id in {}", pathname)?;

        let mut ret = SuiNetworkForTest {
            dtp_package_id,
            sender_addresses: vec![],
        };

        // Get the Sui client addresses (which we will call sender addresses from this point).
        let pathname = format!(
            "{}{}",
            path, "/../../../dtp-dev/publish_data/localnet/client_addresses.txt"
        );
        if let Ok(lines) = SuiNetworkForTest::read_lines(pathname) {
            for line in lines.flatten() {
                ret.sender_addresses
                    .push(SuiAddress::from_str(line.as_str())?);
            }
        }

        assert_eq!(ret.sender_addresses.len(), 5);
        Ok(ret)
    }

    pub fn get_sender_address(&self, client: Sender) -> &SuiAddress {
        // Sui localnet should always have 5 senders.
        //
        // If bailing out here (out of bound), then check if something
        // is not right when client_addresses.txt was loaded.
        match client {
            Sender::Test => &self.sender_addresses[0],
            Sender::LocalClient => &self.sender_addresses[1],
            Sender::LocalServer => &self.sender_addresses[2],
            Sender::PeerClient => &self.sender_addresses[3],
            Sender::PeerServer => &self.sender_addresses[4],
        }
    }

    pub async fn package_exists(
        self: &SuiNetworkForTest,
        _name: &str,
    ) -> Result<bool, anyhow::Error> {
        // Verification using self-contain code (its own SuiClient and all).
        //let sui = SuiClient::new("http://0.0.0.0:9000", None, None).await
        /*
                let objects = sui.read_api().get_objects_owned_by_address(address).await?;
                println!("{:?}", objects);
        */
        Ok(true)
    }

    pub async fn object_exists(
        self: &SuiNetworkForTest,
        object_id: ObjectID,
    ) -> Result<bool, anyhow::Error> {
        // Note: Object not existing not considered an error.

        // Verification using self-contain code (its own SuiClient and all).
        let sui = SuiClient::new("http://0.0.0.0:9000", None, None)
            .await
            .map_err(|e| e.context("Is localnet sui process running?"))?;

        // TODO: Check the different error code to differentiate inexistence from call failure. This is very incomplete.
        let result = sui.read_api().get_parsed_object(object_id).await;

        match result {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    }

    pub async fn address_exists(
        self: &SuiNetworkForTest,
        _address: &SuiAddress,
    ) -> Result<bool, anyhow::Error> {
        // Note: Address not existing not considered an error.

        Ok(true)
    }
}
