---
title: Public Broadcast
contributors: true
editLink: true
headerDepth: 0
---

If not already done, read first the [Architecture](./design.md).

Broadcasting is ideal for distributing static content (e.g. a single-page-application website bundle) or media streaming (e.g. live video).

The key distinctions of a broadcast are:
 * No encryption.
 * There is no connection to receivers (no firewall needed). Consequently this will be implemented with "Broadcast" specialized objects instead of "Transport Control" and "Pipes".

Broadcasters may also require some different crypto-economic capability. Examples:
  
 * A live broadcast is wasteful if there is no one listening... one option will be to let DTP stop streaming until there are enough fund from listeners to cover, say, the production cost of the next 1 minute. DTP would handle the automatic "on air" logic and fairly spread the cost among the contributors.
 * While the broadcasting the receiver may pay for initiating concurrent connection-oriented services (private or group chat, two-way streaming etc...).
 * Receiver may choose to tip a live broadcaster (for special song requests?).

![Broadcast](/assets/images/ref_broadcast.png?url)*<div style="text-align:center">Broadcasting Specific Objects</div>*

There are some technical challenges particular to broadcasting (See [Future Work](./future_work.md#broadcasting-challenges)).

