// DTP SDK API
//
// For most app, only one instance of DTP object will be needed.
//
// There is a one-to-one relationship between a Sui client address
// and a DTP instance.
//
// A DTP object can create multiple child objects, e.g. Host, LocalHost...
// Operations on these childs are enforced to be done only in context of its
// parent.
//
// Multiple DTP instance can co-exist in the same app.
//
// Caller Responsibilities:
//   - Do not instantiate two DTP object for the same client address.
//     It may work, but it may also result in equivocation deadlock of
//     the Sui network and the client might be unuseable until start
//     of next epoch.
//
//   - A DTP instance (and its children) must all be access within a
//     single thread (or be Mutex protected by the caller).
//
//   - Doing operations that mix children with the wrong DTP parent will
//     be detected and result in a TBD error.
//
// TODO Define the error.

use anyhow::bail;
use dtp_core::{
    network::{HostInternal, LocalhostInternal, NetworkManager},
    types::PingStats,
};
use sui_sdk::types::base_types::{ObjectID, SuiAddress};
use tokio::time::Duration;

#[allow(dead_code)]
#[derive(Debug)]
pub struct Host {
    id: ObjectID,
    // Hidden implementation in dtp-core.
    host_internal: HostInternal,
}
impl Host {
    pub fn id(&self) -> &ObjectID {
        &self.id
    }
}

// Similar to Host, but with additional functionality available
// assuming the caller is the administrator of the Host.
#[allow(dead_code)]
pub struct Localhost {
    host: Host,
    // Hidden implementation in dtp-core.
    localhost_internal: LocalhostInternal,
}

impl Localhost {
    pub fn id(&self) -> &ObjectID {
        self.host.id()
    }
}

pub struct DTP {
    // Implementation hidden in dtp-core.
    netmgr: NetworkManager,
}

impl DTP {
    pub async fn new(
        client_address: SuiAddress,
        keystore_pathname: Option<&str>,
    ) -> Result<Self, anyhow::Error> {
        Ok(DTP {
            #[allow(clippy::needless_borrow)]
            netmgr: NetworkManager::new(client_address, keystore_pathname).await?,
        })
    }

    // Light Mutators
    //   JSON-RPC: No
    //   Gas Cost: No
    pub fn set_package_id(&mut self, package_id: ObjectID) {
        self.netmgr.set_package_id(package_id);
    }

    // Light Accessors
    //   JSON-RPC: No
    //   Gas Cost: No
    pub fn package_id(&self) -> &ObjectID {
        self.netmgr.get_package_id()
    }
    pub fn client_address(&self) -> &SuiAddress {
        self.netmgr.get_client_address()
    }
    pub fn localhost_id(&self) -> &Option<ObjectID> {
        self.netmgr.get_localhost_id()
    }

    pub async fn add_rpc(
        &mut self,
        http_url: &str,
        ws_url: Option<&str>,
        request_timeout: Option<Duration>,
    ) -> Result<(), anyhow::Error> {
        self.netmgr.add_rpc(http_url, ws_url, request_timeout).await
    }

    // get_host
    //   JSON-RPC: Yes
    //   Gas Cost: No
    //
    // Get an handle of any DTP Host expected to be already on the Sui network.
    //
    // The handle is used for doing various operations such as pinging the host
    // off-chain server and/or create a connection to it.
    pub async fn get_host(&self, host_id: ObjectID) -> Result<Host, anyhow::Error> {
        let host_internal = self.netmgr.get_host(host_id).await?;
        Ok(Host {
            id: *host_internal.get_sui_id(),
            host_internal,
        })
    }

    // get_localhost
    //   JSON-RPC: Yes
    //   Gas Cost: No
    //
    // Get an handle of the DTP Localhost that your client address control.
    //
    // DTP supports only one Localhost per client address.
    //
    // Can return DTPError::DoesNotExist
    //
    // See create_localhost().
    //
    pub async fn get_localhost(&mut self) -> Result<Localhost, anyhow::Error> {
        let (host_internal, localhost_internal) = self.netmgr.get_localhost().await?;
        let host = Host {
            id: *host_internal.get_sui_id(),
            host_internal,
        };
        Ok(Localhost {
            host,
            localhost_internal,
        })
    }

    // create_localhost_on_network
    //
    //   JSON-RPC: Yes
    //   Gas Cost: Yes
    //
    // Create a new DTP Host on the Sui network.
    //
    // The shared object created on the network will be retreiveable
    // as a read-only DTP::Host handle for everyone (see get_host).
    //
    // For the administrator the same object can also be retreiveable
    // as a read/write DTP::Localhost handle (see get_localhost).
    //
    pub async fn create_localhost_on_network(&mut self) -> Result<Localhost, anyhow::Error> {
        let (host_internal, localhost_internal) = self.netmgr.create_localhost_on_network().await?;
        let host = Host {
            id: *host_internal.get_sui_id(),
            host_internal,
        };
        Ok(Localhost {
            host,
            localhost_internal,
        })
    }

    // Ping Service
    //   JSON-RPC: Yes
    //   Gas Cost: Yes
    pub async fn ping(
        &self,
        _localhost: &Localhost,
        _target_host: &Host,
    ) -> Result<PingStats, anyhow::Error> {
        // Verify parameters are children of this NetworkManager.
        //
        // Particularly useful for the Localhost for an early detection
        // of trying to access with an incorrect client_address
        // (early failure --> no gas wasted).
        /*
        let &parent_id = self.netmgr.id();
        let &source_host = localhost.host;
        if (source_host.get_parent_id() != parent_id) {}

        if (target_host.get_parent_id() != parent_id) {}

        if (source_host.get_object_id() == target_host.get_object_id()) {}

        self.netmgr.ping(localhost, target_host)
        */
        // TODO WIP Obviously...
        let stats = PingStats {
            ping_count_attempted: 1,
            ..Default::default()
        };

        Ok(stats)
    }

    // Initialize Firewall Service
    //   JSON-RPC: Yes
    //   Gas Cost: Yes
    //
    // The firewall will be configureable from this point, but not yet enabled.

    pub async fn init_firewall(&self, localhost: &mut Localhost) -> Result<(), anyhow::Error> {
        // Detect API user mistakes.
        if self.netmgr.get_client_address() != localhost.localhost_internal.get_admin_address() {
            bail!("Localhost object unrelated to this DTP object")
        }

        self.netmgr
            .init_firewall(&mut localhost.localhost_internal)
            .await
    }
}
