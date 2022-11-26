---
description: Inspiration for the long term (no plan for  now)
---

# Future Work

## **Broadcasting Challenges**

Data broadcasting will put traffic load pressure on the fullnodes RPC pub/sub services.\
\
Fullnodes may have low economic incentive to support high bandwidth on their RPC.\
\
The architecture should scale to match the audience size.\
\
Consequently, the solution is for DTP/Sui to provide only the crypto-economic services and then leave the burden of broadcasting to a public peer-to-peer network.\


<figure><img src="../.gitbook/assets/P2P broadcast.png" alt=""><figcaption><p>Broadcasting with P2P for data plane, and direct internet connection for control plane.</p></figcaption></figure>

Each peer is running a DTP app for direct connection to the Sui network (for control plane). The complexity of the data plane transiting through a peer-to-peer network should be hidden to the end-users (Peers).&#x20;

The use of P2P or not remains irrelevant to the broadcaster which always interface directly to the Sui network.

## **Encrypted Broadcasting**

For now, broadcast are assumed to be always public and non-encrypted.\
\
Allowing encryption may allow alternative economic model (similar to cable and/or streaming subscription services), but this is challenging and piracy can (at best) only be mitigated.\
\
Only the user with the decryption key would be able to make sense of the data. More research to be done about how DTP could implement this feature.\
****\
****\[1] Wikipedia [Broadcast Encryption](https://en.wikipedia.org/wiki/Broadcast\_encryption) \
\[2] Wikipedia [Multicast Encryption](https://en.wikipedia.org/wiki/Multicast\_encryption)\
\
\
\
