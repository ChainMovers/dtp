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

#[allow(dead_code)]
pub enum Client {
    DevApp = 0,
    Demo1 = 1,
    Demo2 = 2,
    Test1 = 3,
    Test2 = 4,
}

pub struct SuiNetworkForTest {
    pub dtp_package_id: ObjectID, // Last package that was published.

    // localnet provides 5 owner addresses with funds.
    //
    // These addresses are "reserved" in a way that various process
    // won't interfere with each other.
    //
    //        0: Reserved for dtp-dev-app.
    //   [1..2]: Reserved for demo with DTP daemon.
    //   [3..4]: Reserved for dtp-sdk integration tests.
    //

    // Use get_client_address() for access.
    client_addresses: Vec<SuiAddress>,
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
            client_addresses: vec![],
        };

        // Get the client addresses.
        let pathname = format!(
            "{}{}",
            path, "/../../../dtp-dev/publish_data/localnet/client_addresses.txt"
        );
        if let Ok(lines) = SuiNetworkForTest::read_lines(pathname) {
            for line in lines.flatten() {
                ret.client_addresses
                    .push(SuiAddress::from_str(line.as_str())?);
            }
        }

        assert_eq!(ret.client_addresses.len(), 5);
        Ok(ret)
    }

    pub fn get_client_address(&self, client: Client) -> &SuiAddress {
        // Sui localnet should always have 5 clients.
        //
        // If bailing out here (out of bound), then check if something
        // is not right when client_addresses.txt was loaded.
        match client {
            Client::DevApp => &self.client_addresses[0],
            Client::Demo1 => &self.client_addresses[1],
            Client::Demo2 => &self.client_addresses[2],
            Client::Test1 => &self.client_addresses[3],
            Client::Test2 => &self.client_addresses[4],
        }
    }

    pub async fn object_exists(
        self: &SuiNetworkForTest,
        _id: &ObjectID,
    ) -> Result<bool, anyhow::Error> {
        Ok(true)
    }

    pub async fn address_exists(
        self: &SuiNetworkForTest,
        _address: &SuiAddress,
    ) -> Result<bool, anyhow::Error> {
        Ok(true)
    }
}
