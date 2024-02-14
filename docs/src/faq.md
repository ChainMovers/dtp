---
editLink: true
---
# FAQ

**In one sentence... What can DTP do?**

It is a TCP-Like protocol facilitating data transfer between web2 applications, with additional Web3 features such as services monetization, anonymity and security.

**Can DTP be used between Web3 apps?**

DTP can selectively connect front-ends WebApp to each other, while keeping the data transfer under the control of a dApps (transit on the Sui network).

As an example, you can use it to allow gamers safely exchange encrypted messages among themselves while they are on the same team in a Web3 game. In this case, DTP provides the WebApp to WebApp connectivity without making the players IP addresses visible.


**What sort of data can DTP transport?**

Any protocol, any data stream.

Data can be a few bytes for a one time secret exchange for authentication/login. At another extreme, the bandwidth can be for as much as an encrypted video stream (through the innovative combination of [DTP Multi-channels](docs/design.md#multi-channel-connection) and Sui network simple transactions). The economic feasibility of HD video streaming on blockchain is an open question...

**Can DTP be used with commercial application?**

Yes. DTP is open-source and can freely be used in commercial application ([Apache 2.0 License](../../LICENSE)).

**How much does it cost to use DTP?**

Only the Sui gas needed to run it, expect the execution cost to be mostly driven by the number of bytes transferred.

There is no developer fee or middlemen commission collected for using DTP.

**When will DTP have token?**

Never. 

dApps built on top of DTP can use tokens or charge additional Mist, but this is not within the scope of DTP itself.

**Can DTP simply tunnel standard TCP, UDP, IP packets?**

Transparent packets tunneling could be done, but it is not recommended.

DTP/Sui provides already reliable and ordered data transport. That would be redundant with say, what TCP would try to achieve within a tunnel.

Instead, look into [DTP Services Daemon](how-to/install.md#choice-1-of-3-simplified-dtp-services-deployment) to efficiently terminate/bridge standard IP protocols. That eliminates protocol redundancy and better leverage what the Sui network already provide.

**Any plan to support another blockchain?**

No, unless a breakthrough in performance is possible with another blockchain architecture.

Sui provides stable time to finality (low jitter), parallelism and scalability (no contention between connections).

Low jitter allows small and predictable buffer size at the receivers.

Sui simple transactions makes sub-second streaming latency possible.

For now, DTP/Sui might not be well-suited for application that depends on fast sequence of query/response (since that requires two transactions finality). DTP attempts to minimize roundtrips and protocol handshakes at every step.

**Where is the code?**

DTP still in early design phase and is not yet release. 
See [GitHub](https://github.com/mario4tier/dtp) development branches for "work-in-progress".

**Where can I go for more questions?**

Try the Discord channel: [https://discord.gg/Erb6SwsVbH](https://discord.gg/Erb6SwsVbH)