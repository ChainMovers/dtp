
# Future Work

## **Broadcasting Challenges**

Data broadcasting will put pressure on fullnodes WebSocket event streaming services.

Fullnodes may have low economic incentive to support such high bandwidth services.

The architecture should scale to match the audience size.

Consequently, one possible **long term** solution is for DTP/Sui to provide only the crypto-economic services and then leave the burden of broadcasting to a public peer-to-peer network.

<figure markdown>![](../assets/images/p2p_broadcast.png)</figure>

Each peer is running a DTP app for direct connection to the Sui network (for control plane). The complexity of the data plane transiting through a peer-to-peer network should be hidden to the end-users (Peers).&#x20;

The use of P2P or not remains irrelevant to the broadcaster which always interface directly to the Sui network.

## **Encrypted Broadcasting**

For now, broadcast are assumed to be always public and non-encrypted.

Allowing encryption may allow alternative economic model (similar to cable and/or streaming subscription services[^1]), but this is challenging and piracy can (at best) only be mitigated[^2].

Only the user with the decryption key would be able to make sense of the data. More research to be done about how DTP could implement this feature.


[^1]: Wikipedia [Broadcast Encryption](https://en.wikipedia.org/wiki/Broadcast\_encryption)

[^2]: Wikipedia [Multicast Encryption](https://en.wikipedia.org/wiki/Multicast\_encryption)