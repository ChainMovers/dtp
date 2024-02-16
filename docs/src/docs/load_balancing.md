---
title: Load Balancing
contributors: true
editLink: true
headerDepth: 0
---

If not already done, read first the [Architecture](./design.md).

## Off-Chain Single Cluster Load Balancing
A DTP Services daemon can dispatch the connections to multiple servers. This mitigate some scalability and availability issues. The DTP Services daemon remains a single point of failure though.

Note: This feature was already implemented for JSON-RPC high availability by Suibase in 2023. This will be integrated into the DTP Services daemon in 2024.

## On-Chain Multi-Cluster Load Balancing
This optional feature is an enhancement to the [off-chain single cluster load balancing](#off-chain-single-cluster-load-balancing).

It enables better availability by avoiding having a single server (point of failure) dispatch all the traffic. 

This features add "worldwide" dispatching consensus and by-design works great for coordinating servers regardless of their location. It also helps mitigate "split brain" network problems (e.g. when servers in a region can't coordinate with the rest but they are still able to serve their share of DTP connections).

![](/assets/images/ref_ha.png?url)
*<div style="text-align:center">Forwarding decision made by Pipe object when multiple end-points (servers)</div>*

Unlike traditional network, the data is not physically pushed toward a server. Instead, the data remains on the network and an event is emitted about **who** should pull it. The **who** question is "best effort" answered by this on-chain logic.

It is the responsibility of the servers to subscribe to their respective event stream and normally respond only to its assigned data (this change in some recovery/retry scenario).

Configuration of the end-points and their health is managed through the DTP Host object, which in turn eventually updates all its transport control objects and pipes.

The combination of this on-chain logic and DTP Service Daemon will hide the high complexity of automatic recovery/retry logic with a different server.

Note: The complexity of load balancing is not visible to the senders. This is all configured and handled on the receiving end.
