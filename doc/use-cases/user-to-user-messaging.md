---
description: <<Work in progress>>
---

# Applications Example

Here are a few ideas that can be built on top of DTP. \
\
If not sure how to proceed, please open a discussion on [Discord](https://discord.gg/Erb6SwsVbH).\
\
**Client/Server**

* Web3 frontends connecting to a centralized JSON-RPC backend ( [More info](json-rpc-firewall.md) )
* Rust/Typescript Web3 Client to centralized TCP Server ( [More info](rust-client-server.md) )

**Messaging**

* Encrypted user-to-user data transfer&#x20;
* Anonymous Tips Line (with potential reward in return).

**Networking / Infrastructure**

* Zookeeper, Consul, Serf-like services for discovery and consensus among off-chain servers.
* UDP, TCP, QUIC/UDP Tunneling: Transport IP protocols packets within a DTP connection for point-to-point applications (See [DTP Services Daemon](../intro/installation.md#setup-with-dtp-services-daemon-plan-for-april-2023) for an alternative)

**Firewall**

* Rate limit access to a back-end server (either bandwidth or request)
* Allow/block origin (using authentication)

**Crypto-Economics**

* Any service charging for content access (in addition to DTP cost). DTP to provide per byte and/or per request escrow service (to meter pre-agreed cost, limit and quantity... not quality).
* Pre-paid subscription per day/month (epoch driven?).
* Various escrow service that allows to shift the transport cost completely at the origin or destination (gas always paid by sender, but escrow service handles fair refund).

**Public Broadcasting**

* Allow anyone listen to authenticated, censorship resistant broadcasting, with some built-in crypto economics to pay for some (or more?) of the production fee (e.g., broadcast upon enough fund contributed).



