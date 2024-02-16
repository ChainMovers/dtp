---
title: Architecture
contributors: true
editLink: true
headerDepth: 0
---

## Target Audience
Developers should first read the API they intend to use.

The design section is for developers curious about DTP inner works.

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
The owned objects on the data plane (e.g. Pipe) need to synchronize periodically with the control plane. This is for forwarding traffic statistic, apply latest firewall commands and bring the escrows to resolution.

The control plane typically uses shared object. Involving a single Pipe object with a slow consensus would cause a 2-3 seconds blocking of the data plane. This is unacceptable if streaming audio/video.

Therefore, a owned Pipe is actually assisted by InnerPipe owned objects. The synchronization between InnerPipe and the slower control plane is done in two steps.

 1. Each InnerPipe is sequentially "fast synch" with its related Pipe (all fast path).
 2. The Pipe object is "slow synch" with the control plane. This is a consensus transaction.

![](/assets/images/design_inner_pipe_2.png?url)

With this design, the data plane flows at "full speed" while keeping all objects **eventually** synchronized.

The receiver re-assemble the data stream from what is observed from all flowing InnerPipes (DTP has sequence numbers for re-ordering).


A fast path sync looks like:
```
  fun fast_sync( pipe: &mut Pipe, inner_pipe: &mut InnerPipe ) 
  {
    // ... quickly exchange data plane stats, latest control plane commands etc...
  }
```

The slow consensus sync is:
```
  fun slow_sync( pipe: &mut Pipe,                  
                 transport_control: &mut TransportControl )
  {
    // ... does slow control plane operation ...
  }
```

The fast path data flowing is:
```
  fun fast_data_send(inner_pipe: &mut InnerPipe, data: vector<u8>) 
  {
    // ... does a fast data plane transmission ...
  }
```

Of course, the sender has to be extra careful about equivocation.

Note 1: DTP "forces" the sender (Pipe/InnerPipe owner) to collaborate. An InnerPipe will automatically block when not "sufficiently" synchronized (e.g. block after 20 transaction without sync). If the sender choose to not follow the "sync" protocol, then the whole Pipe will eventually be blocked/useless. At worst, any party can "hangup" the connection and let DTP do fair final escrows resolutions.

Note 2: All this design is encapsulated within the DTP protocol and SDKs. The complexity will not be visible at the DTP API level.

## Video Streaming

A media byte stream is eventually divided into transaction. A serialization of these transactions would limit quickly the bandwidth because of the **Sui finality time** and **maximum transaction size**.

To support high bandwidth, DTP uses multiple InnerPipes for parallel fast path transactions (See [Non-Blocking Data Plane](#non-blocking-data-plane)).

Most of the complexity is handled off-chain by DTP when dividing and re-assembling the transactions into a data stream.

**Will this be practical?**
There is still some cost/performance/implementation unknowns that might persist until DTP is further develop...

Gas might get too expensive, there is also some potential issues with Sui fullnodes performance... (problem at egress of the network, not with the consensus performance itself).

Some estimations (See on [Google Sheet](https://docs.google.com/spreadsheets/d/1zBrB1ifhPpnLlsDr6nBN\_N55Kkw9hX06a7EVUpogyn4/edit?usp=sharing)):

![](/assets/images/multi_channel_est.png?url)
*<div style="text-align:center">(Note: Numbers are best guess as of 02/14/24. Will be revised from time to time)</div>*</br>
