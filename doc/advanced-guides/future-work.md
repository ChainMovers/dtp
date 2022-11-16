---
description: Inspiration for the long term (no plan for  now)
---

# Future Work

### TCP, UDP and QUIC support

Make existing traditional application "just work" by having the DTP local daemon act as a proxy:\
\
![](<../.gitbook/assets/udp\_tcp\_proxy (1).png>)\
\
(**Side Note**: It would not make sense to simply "tunnel" TCP packets through a L1 network. As an example, the 3 way handshakes required to initiate a TCP connection would take tens of seconds. The DTP proxy terminates the TCP, UDP connections and leverage DTP/Sui capability instead)\
\
One difficulty is to resolve the mapping between IP and Sui address. This could be resolved through an UI (or config file), but this is less than ideal.\
\
An alternative would be the notion of "Sui VPN". The servers public IP should still not be visible to peers, but would be NAT translated to an IP on the "VPN". DTP would then provide a DNS service mapping between: \
&#x20;                 Sui domain name <--> Sui address <--> IP VPN address\
\
Note that there is no global storage on the Sui network, so not clear (yet) how DNS would work here (off-chain service? How to trust?)\
![](../.gitbook/assets/udp\_tcp\_vpn.png)

### L1 Network Ephemeral Data&#x20;

The notion of persisting all transactions on a ledger makes sense for traceability of financial transactions.\
\
Persistence quality is not as obvious for encrypted data after it was consumed by the intended receiver.

Data persistence might be optional (or maintain as long users are willing to access+finance its persistence on the network). \
\
At high level, the L1 network would automatically and quickly dispose of encrypted data that has no further use.\
\
One solution would be the addition (not replacement) of a new L1 network Sui consensus with a different balance of "performance vs decentralized" quality. That is, only the "heavy" transfer of "ephemeral data" would be handled by a new Sui L1 specialized consensus.\
\
Since Sui L1 network design is way beyond the control of DTP, a less ideal alternative would be to side-chaining with another L1 network specialized for data streaming.\
\
\
\
