# Applications Example

DTP provides networking building blocks that can be applied in many ways.

You will find on this page a few inspiring ideas.

DTP features are made available in roughly 3 layers (in increasing level of difficulty):

- <b>DTP Services Daemon</b> Similar to NGINX/Cloudflare/HAProxy. These are for proxy/forward/firewall services. You will simply be *configuring* how your data flows between your apps and hosts.

- <b>DTP Protocols</b> Think "TCP". The DTP/Sui SDKs allows developers to create connections between web2 and web3 apps. You will need to write Rust and/or Typescript apps.
  
- <b>DTP Sui Move Packages</b> Innovations particular to Sui, such as RPC escrows, data streaming, coins&call equivocation mitigation, metering etc... you will likely be deeply involve into web3 development at this point.

For most users, you will deal only with the "easiest" layer, the "DTP Services Daemon".

If not sure how to proceed for your specific need, then please open a discussion on [Discord](https://discord.gg/Erb6SwsVbH).

When ready [:octicons-arrow-right-24: Go to choose your installation setup ...](setup/help.md).

**Client/Server**

* Web3 frontends connecting to a centralized JSON-RPC backend ([More info](example/rpc_firewall.md))
* Rust/Typescript Web3 Client to centralized TCP Server ([More info](example/web3_rust.md))

**Encrypted Messaging**

* Add traditional user/password login to a dApp. The goal is to allow access to the same "user account" even if done from a different wallet (client address). Implementation often requires "secret messaging" between a centralized server and the Web3 apps.
* Any user-to-user data transfer&#x20;
* Anonymous Tips Line (with potential reward in return).

**Networking / Infrastructure**

* Zookeeper, Consul, Serf-like services for discovery and consensus among off-chain servers.
* UDP, TCP, QUIC/UDP Tunneling: Transport IP protocols packets within a DTP connection for point-to-point applications (See [DTP Services Daemon](setup/help.md#choice-1-of-3-simplified-dtp-services-deployment) for an alternative)

**Firewall**

* Rate limit access to a back-end server (either bandwidth or request)
* Allow/block origin (using authentication)

**Crypto-Economics**

* Any service charging for content access (in addition to gas cost). DTP provides generic per byte and/or per request escrow service (to meter pre-agreed cost, limit and quantity... not quality).
* Pre-paid subscription per day/month (epoch driven?).
* Various escrow service that allows to shift the transport cost completely at the origin or destination (gas always paid by sender, but escrow service handles fair refund).

**Public Broadcasting**

* Allow live broadcasting to automatically turn on/off upon enough fund contributed (thus saving the producer from any expense when no-one is listening).
* Public broadcast performed upon enough ticket sold.
* Tip/Request/Message/Audience participation line attach to a public event channel.
