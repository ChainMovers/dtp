---
title: Design
contributors: true
editLink: true
headerDepth: 0
---

## Target Audience

Developers should first read the API they intend to use.

This document is for developers curious about DTP inner works.

## At high level, how is the Sui Network used?

Sui owned objects are used for unidirectional data transfer with sub-second latency (See [Fast Path Transactions](https://docs.sui.io/concepts/transactions/transaction-lifecycle) in Sui docs).

Data Ingress: A data stream is sliced into transactions (txns) and added to the Sui network. The txns are targeted to a destination Pipe (owned object).

Data egress: The data "exit" the network through event streams (emitted by the txns executed for the destination Pipe). The data can be "observed" by any users, but decoded only by the ones having the decryption key.

The receiving end DTP SDK re-assembles the txns into the original data stream. The stream is then forwarded to the intended end-user (a TCP server, a Rust application layer above etc...).

Slower transactions (Sui consensus) are used for most "control plane" synchronizations (e.g. opening a connection)

 
## DTP Glossary

![](/assets/images/design_terms.png?url)

**Client**: An application that initiate a connection.

**Connection:** One connection allows exchanging data between two applications. The applications are localized by their Host object on the Sui network. A connection will start to exchange data only after a Transport Control and one or two Pipe objects are created (for uni or bidirectional transfer respectively).

**Host Object**: Any signature authority that want to transfer data must create its own Host object. This object is involved in many control plane transactions. It allows to configure the services (and SLA) that are to be provided and control some firewall functions (e.g. limit maximum number of simultaneous open connections).

**Objects:** Usually refer to Sui objects (See [Sui Docs](https://docs.sui.io/concepts/object-model)

**Pipe Object**: All off-chain data exchange involves an intermediate object on the Sui network. This object is the Pipe. It is owned by the sender of the data, and have its event stream observed by the receiver(s). A Pipe is loosely coupled to a Transport or Broadcast Control object for synchronization.

**Server**: Off-chain process intended to respond to client requests.

**Service Level Agreement (SLA)**: Specify the costs, limitations and some behaviors for a service provided by a Host object. Example would be "sent data can be deleted from network storage after 48 hours (2 epochs)". The client signifies that it agrees to an SLA at the time the connection to the node is initiated. The SLA specs are such that DTP can enforce the agreement fairly to all parties.

**Transport Control Object**: Variables and state machines that exists for the lifetime of a single connection. This is a Sui shared object.

## Firewall

![](/assets/images/ref_firewall.png?url)

(1) Gas cost of processing incoming traffic is paid by the sender. That includes connection creation cost and running the firewall at the Pipe Object. Most abuse can therefore be neutralized without requiring any processing/cost from the Server.

Firewall functionality also includes back pressure management to minimize initiating/paying for transactions while the server is already known offline or too busy.

(2) Optionally, the DTP Host object gather statistics from all its Pipe objects and can adjust the traffic policies, as an example to block an abusing sender. (Note: Synchronization with owned object is a **logical** representation. See [Non-Blocking Data Plane](#non-blocking-data-plane) for more design details).

(3) The server configure the firewall and does a periodical heartbeat using its shared DTP Host object. The DTP services daemon can also be configured to further actively control the firewall depending of its load (TBD).

(4) When a transmission is block because of the firewall, there is no event emitted (and sender is informed with a transaction error). Statistics are accumulated, but the Server is not impacted.


## Non-Blocking Data Plane
A single owned Pipe object used as part of a transaction requiring slow consensus would cause a blocking of the data plane in the order of seconds. This is unacceptable if streaming audio/video.

Therefore, a DTP Pipe is actually composed of independent InnerPipe owned objects. One InnerPipe can be block and used as part of a slow consensus while the others keeps "flowing" with fast path transactions.

<img src="/assets/images/design_inner_pipe.png?url" style="display:block; margin-left: auto; margin-right: auto;"/>

The receiver will re-assemble the data stream coming from all flowing InnerPipes (does not matter which one, DTP has sequence numbers for re-ordering).

Note: Every InnerPipe needs periodical synchronization with the control plane to exchange statistics and enforce traffic rules. DTP "forces" the sender (object owner) to collaborate by making an InnerPipe automatically blocked if not recently synchronized with the control plane. If the sender choose to not follow the "sync" protocol, then the whole Pipe will eventually be blocked.

A Sui slow consensus synchronization will look like this:
```
  fun slow_sync( pipe: &mut Pipe, 
                 inner_pipe: &mut InnerPipe, 
                 transport_control: &mut TransportControl )
  {
    // ... does a slow control plane operation ...
  }
```

A Sui fast path transaction will be:
```
  fun fast_data_send(inner_pipe: &mut InnerPipe, data: vector<u8>) 
  {
    // ... does a fast data plane transmission ...
  }
```


## Video Streaming

A media byte stream is eventually divided into transaction. A serialization of these transactions would limit quickly the bandwidth because of the **Sui finality time** and **maximum transaction size**.

To support high bandwidth, DTP uses multiple InnerPipes for parallel fast path transactions (See [Non-Blocking Data Plane](#non-blocking-data-plane)).

Most of the complexity is handled off-chain by DTP when dividing and re-assembling the transactions into a data stream.

**Will this be practical?**
There is still some cost/performance/implementation unknowns that might persist until DTP is further develop...

Gas might get too expensive, there is also some potential issues with Sui fullnodes performance... (problem at egress of the network, not with the consensus performance itself).

Some estimations (See on [Google Sheet](https://docs.google.com/spreadsheets/d/1zBrB1ifhPpnLlsDr6nBN\_N55Kkw9hX06a7EVUpogyn4/edit?usp=sharing)):

![](/assets/images/multi_channel_est.png?url)
*<div style="text-align:center"><small style="color:red;">(Note: Numbers are best guess as of 02/14/24. Will be revised from time to time)</small></div>*</br>


## High-Availability and Load Balancing

![](/assets/images/ref_ha.png?url)
*<div style="text-align:center">Forwarding decision made by Pipe object when multiple end-points (servers)</div>*

Off-chain servers can share the incoming load or be each other's fallback for high-availability.

Unlike traditional network, the data is not physically pushed toward a server. Instead, the data remains on the network and an event is emitted about who should "pull it".

It is an off-chain responsibility for the application to subscribe to their respective event stream (with proper identifier filtering) and normally retrieve only its assigned data (this change in some recovery scenario).

Configuration of the end-points and health of the servers is managed through the DTP node, which in turn updates all its pipes and transport control objects.

DTP will hide the high complexity of many race conditions (assignment to a server that died) and connection migrations among all end-points belonging to the same Node.

## Uni-directional Transfer
Similar to bi-directionals, but with a single Pipe object for data plane to minimize cost/complexity. Control plane still bi-directional (e.g. for encryption handshake).

![](/assets/images/ref_uni.png?url)*<div style="text-align:center">Uni-Directional Data Transfer</div>*



## Public Broadcasting

Similar to unidirectional, but without encryption and using Broadcast objects instead of a Pipe&Transport control.

![](/assets/images/ref_broadcast.png?url)*<div style="text-align:center">Broadcasting Specific Objects</div>*


Broadcasters may require some different crypto-economic capability. Examples:

* A live broadcast is wasteful if there is no one listening... one option will be to let DTP stop stream until there are enough fund from listeners to cover, say, the production cost of the next 1 minute. DTP would handle the automatic "on air" logic and fairly spread the cost among the contributors.
* Listener may choose to tip a live broadcaster (for special requests?).

There are also some technical challenges particular to broadcasting (See [Future Work](future_work.md#broadcasting-challenges)).