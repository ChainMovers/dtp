# FAQ

**Can DTP be used with commercial application?**\
Yes.\
DTP is open-source and can freely be used in commercial application ( [Apache 2.0 License](../../LICENSE) ).\
\
**How much does it cost to use DTP?**\
****DTP costs is only the Sui gas needed to run it.\
\
There is no developer fee or commission collected for using DTP.\
<\<TODO add here estimated Sui cost per byte etc...>>\
\
**When will DTP have token?**\
****Never. \
\
dApps built on top of DTP can use tokens and/or charge additional Mist, but this is not within the scope of DTP itself.\
\
**Can DTP simply tunnel standard TCP, UDP, IP packets?**\
****Packets tunneling could technically be done, but is not recommended.\
\
DTP/Sui provides reliable and ordered data transport. That would be redundant with, say, what TCP would try to achieve within a tunnel.

Instead, look into [DTP Services Daemon](installation.md#setup-with-dtp-services-daemon-plan-for-april-2023) to efficiently terminate/bridge standard IP protocol with DTP.\
\
**Any plan to support another blockchain?**\
****No, unless a breakthrough in performance is possible with another blockchain architecture.

Sui has been selected because of its qualities to provide stable time to finality (low jitter) and parallelism (no contention between connections).\
\
Low jitter allows for reasonably small and predictable buffer size at the receivers.

Furthermore, with Sui simple transaction a stream latency is sub-second. \
\
For now, DTP/Sui might not be well-suited for application that depends on fast sequence of query/response (since that requires two transactions finality). There is a lot of effort put into DTP to minimize roundtrips and protocol handshakes.\
\
**Where is the code?**\
****DTP still in early design phase and is not yet release. \
See [GitHub](https://github.com/mario4tier/dtp) development branches for "work-in-progress".

\
**Where can I go for more questions?**\
Try the Discord channel: [https://discord.gg/Erb6SwsVbH](https://discord.gg/Erb6SwsVbH)\
