# FAQ

**Can DTP be used with commercial application?**\
Yes.\
DTP is open-source and can freely be used in commercial application ( [Apache 2.0 License](../../LICENSE) ).\
\
**How much does it cost to use DTP?**\
****The DTP layer is operated only with the Sui gas needed to run it.\
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
DTP leverage the quality that the Sui L1 network already provides (e.g. ordering, reliability...) and would be redundant with, say, what TCP would try to also achieve within a tunnel.

Instead, look into "DTP Services Daemon" to efficiently terminate/bridge standard IP protocol applications with DTP.\
\
**Any plan to support another blockchain?**\
****Not on short term. Sui has been selected because of its quality to provide stable time to finality and parallelism (no contention between connections).\
\
This makes unidirectional streaming practical because of a more predictable buffer time required at the receivers.\
\
For now, DTP might not be well-suited for application that depends on a lot of query/response (since that requires two transaction finality on the network), but there is a lot of effort put into DTP to minimize roundtrips.\
\
**Where is the code?**\
****DTP still in early design phase and is not yet release. \
See [GitHub](https://github.com/mario4tier/dtp) development branches for "work-in-progress".

\
**Where can I go for more questions?**\
Try the Discord channel: [https://discord.gg/Erb6SwsVbH](https://discord.gg/Erb6SwsVbH)\






