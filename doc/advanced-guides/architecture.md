---
description: <<Work in progress. High level for now, exhaustive specs later>>
---

# Architecture

## Target Audience

Developers should first read the SDK documentations for how to use DTP.

The architecture document is intended for developers modifying DTP itself.



## DTP Connection Types

At functional level, DTP is similar to TCP but differs significantly in its implementation to benefit from what is already provided by the L1 network.

There are 3 types of data transfer:

* Bidirectional : Connection-oriented (like TCP) between two end-users. Always encrypted.
* Unidirectional: Also connection-oriented between two end-users (for encryption), but heavy data flows only in one direction.
* Public Broadcast: Anyone can receive and observe the authenticated stream of data. This is the only transfer mode without encryption. Requires a different set of object/API calls to avoid accidently broadcasting.

DTP data is originated using Sui transactions.\
The data is received through event streams.\


## DTP Address

The typical \<IP address>:\<Port> becomes a \<Host Sui Address>:\<Port>\
\
SuiNS will be evaluated for DNS.

## At high level, how is the Sui Network used?

Sui owned objects are used for unidirectional data transfer with sub-second latency (See [Simple Transaction](https://docs.sui.io/devnet/learn/how-sui-works#simple-transactions) in Sui docs).

Data Ingress: A data stream is sliced into transactions (txns) and added to the Sui network. The txns are targeted to a destination Pipe.

Data egress: The data "exit" the network through event streams (emitted by the txns being received at the destination Pipe). The transmitted data can be "observed" by any users, but decoded only by the ones having the decryption key.\
\
The receiving end DTP SDK re-assembles the txns into the original data stream. The stream is then forwarded to the intended end-user (a TCP server, a Rust application layer above etc...).\
\
Slower transactions (Sui consensus) are used for most "control plane" synchronizations. \


## DTP Glossary

<figure><img src="../.gitbook/assets/terminology_1.png" alt=""><figcaption><p>Example of two connections between 3 end-users</p></figcaption></figure>

**Client**: End-point initiating a bi-directional connection with a Node.

**Connection:** One connection allows to exchange data between two end-users. Can be uni or bi-directional. An end-user creates a connection by calling a function into the destination DTP Node object (See [Connection API](dtp-built-in-services/connection-api.md)).

**End-Point**: An off-chain process that can send/receive data. An end point can handle multiple local end users, protocols and connections simultaneously (each independently encrypted).

**End-User**: A signature authority that can send/receive data.

**Node Object**: Any end-user that want to transfer data must create its own Node object. This is a Sui shared object involved in many control plane transactions (e.g. creation of a connection). The node allows to configure the services (and SLA) that are to be provided, the lifecycle of its associated connections, the management of its end-points. Nodes also control the firewall.\
Nodes are shared Sui object.

**Objects:** Usually refer to on-chain Sui objects ( See [Sui Docs](https://docs.sui.io/build/programming-with-objects) )

**Pipe Object**: End-points can never directly exchange data with each other directly (their IP is not known to the peer). All data plane transfers involves an intermediate object on the Sui network. One pipe is required per direction of a connection. A pipe can from time to time change the endpoint for high-availability or load balancing (if the end-user have configured multiple end-point to its Node). Pipe are owned Sui objects (owner is the sender of the data stream).\
\
**Server**: End-point intended to respond to client requests.\
\
**Service Level Agreement (SLA)**: Specify the costs, limitations and some behaviors for a service provided by a Node object. Example would be "sent data can be deleted from network storage after 48 hours (2 epochs)". The client signify that it agrees to a SLA at the time the connection to the node is initiated. The SLA specs are such that DTP can enforce the agreement in a fair way to all parties.

**Transport Control Object**: Variables and state machines that exists for the lifetime of a single connection. This is a Sui shared object.

## Firewall

Set of DTP built-in features protecting and enforcing fair use of the off-chain applications. \
\
Includes:

* Protect the receiver by allowing/blocking/limiting new connections depending of the sender address.
* Rate limiting on a per-connection basis. The control is mostly done from the off-chain server, but metering and some limiting is handled on-chain.&#x20;
* On long term considering also on-chain escrow services for service level agreement (SLA) between client and server.
* Protect the sender from initiating/paying for transactions while the server is already known offline or too busy (backpressure management). This could allow the sender to more quickly fallback to another server.\


DDoS are unlikely since the burden of gas execution is mostly on the sender. Still a firewall is useful in case of financial attack on the service provider (exploitation of a request cost being low versus the cost of responding).\


<figure><img src="../.gitbook/assets/firewall.png" alt=""><figcaption><p>Built-in Firewall Capabilities</p></figcaption></figure>

Details on the illustration:

(1) Gas cost of processing incoming traffic is paid by the sender. That includes connection creation cost and running the firewall at the Pipe Object. Most abuse can therefore be neutralized without requiring any processing/cost from the Server.

(2) Optionally, the DTP Node object can gather statistics from all its Pipe objects and adjust the rate limiting rules. This may happen when the Server detects excessive incoming traffic. The gas cost for these likely rare adjustments are to be handled by the Server. (Note: This is a logical representation. More details will follow on how this is implemented such that Pipe objects are not involved with slower consensus transactions).\
\
(3) The server configure the firewall and does a periodical heartbeat using its shared DTP Node object. The server may also do some fast detection and control on the firewall (TBD).\
\
(4) When a transaction has no-effect because of the firewall, there is no event emitted (and sender is inform that the transaction was executed, but blocked by the firewall). Therefore the Server is not impacted.\
\


## Multi-Channel Connection

Data is transmitted as a stream and therefore must be divided into smaller transactions. Even with a fast finality, the bandwidth is limited by the maximum transaction size.\
\
Multiple simple transactions executed in parallel can provide higher bandwidth for a single connection.\
\
Most of the complexity will be in the off-chain end-points when dividing and re-assembling the data stream:

<figure><img src="../.gitbook/assets/multi-channels.png" alt=""><figcaption></figcaption></figure>

**Will this be practical?**\
There is a lot of cost/performance unknowns with both Sui network and DTP that will probably persist through 2023. DTP architecture is planning for supporting heavy media streaming, but it remains to be seen how practical it will be.\
\
Gas might be expensive and there is some potential limitations about how much Sui fullnodes could scale on a viral broadcast (problem at egress of the network, not with the consensus performance itself).\
\
Light data streaming (<20 Kbps) very likely to be supported and be useful within 2023.\
\
Regardless of practicality, support for multi-channel will be at least useful for demo/stress load on a test network.\
\
Some estimations ( See on [Google Sheet](https://docs.google.com/spreadsheets/d/1zBrB1ifhPpnLlsDr6nBN\_N55Kkw9hX06a7EVUpogyn4/edit?usp=sharing) ):

<figure><img src="../.gitbook/assets/multi_channel_est.PNG" alt=""><figcaption></figcaption></figure>

&#x20;            <mark style="color:red;">(Note: Numbers are best guess as of 11/21/22. Will be revised from time to time)</mark>



## Uni-directional Connection

<figure><img src="../.gitbook/assets/uni-directional.png" alt=""><figcaption><p>Uni-Directional Connection. One direction data plane, but still bi-directional control plane.</p></figcaption></figure>

Pipe object are unidirectional for the data transfer (two needed for a bi-directional connection).\
\
Although the data is intended to flow in one direction, some lightweight bi-directional exchanges still happens at various point:\
\
(1) When the connection is created, some bi-directional exchange happen between the source end-point and the destination DTP Node object.\
\
(2) Exchange between end-points through the "Transport Control Object". This relates mostly to the encryption protocol and application of the Service Level Agreement.

(3) Pipe are not **purely** unidirectional. Sender interactions with a Pipe are done with transactions, which means a return value for some immediate responses (e.g. the data was not sent because of a receiver firewall rule).

## High-Availability and Load Balancing

<figure><img src="../.gitbook/assets/ha (1).png" alt=""><figcaption><p>Forwarding decision made by Pipe object when multiple end-points (servers) </p></figcaption></figure>

Off-chain servers can share the incoming load or be each others fallback for high-availability.

Unlike traditional network, the data is not physically pushed toward a server. Instead, the data remains on the network and an event is emitted about who should "pull it".\
\
It is an off-chain responsibility for the application to subscribe to their respective event stream (with proper identifier filtering) and normally retrieve only its assigned data (this change in some recovery scenario).\
\
Configuration of the end-points and health of the servers is managed through the DTP node, which in turn updates all its pipes and transport control objects.\
\
DTP will hide the high complexity of many race conditions (assignment to a server that died) and connection migrations among all end-points belonging to the same Node.

## Data Deletion

Once the data is confirmed consumed by the receiver(s), then it can be deleted on the L1 network to recover some storage fee <\<Revisit the design needed here once Sui implements Storage fund>>.\
\
The sender of the data can opt-out from automated deletion and assume the full storage cost.\
\
Automated deletion is controlled by DTP to provide a fair time for the receiver(s) to consume the data and can be fine tuned through the sender service level agreement (SLA).\
\
The SLAs are publish by the server (in its Node object) and one is selected by the client at the time of the connection being established.

## Data Consumption Confirmation

TCP protocol includes acknowledgment of L4 delivery to the destination, but without guarantee of being consumed by the application (requires additional protocol at layer 7). \
\
DTP layer supports both; a confirmation of the data being available on the L1 network (TCP delivery equivalent) and optional confirmation of the client consuming the data (L7 protocol equivalent).\
\
Example of use would be to integrate in the dApps the verification that the data was persisted off-chain by the destination. There is no verification that the destination is honest, but this would be used in context where it would be in the destination best interest to act honestly.\
\
Another benefit for data confirmation is to shorten the time that the data need to be preserved on the network, therefore saving storage fee for the sender. \
\
The "consumed state" is controlled by the receiving application above DTP (the app call a function in the SDK to confirm consumption).\
\
In some use case, the sender may choose to stop transferring further data until the receiver confirm consuming some of the oldest data, therefore motivating the receiver to remain honest. All this will be done under the supervision of DTP for honest handling of the connection service level agreement (SLA).

## Public Broadcasting

Similar to unidirectional, but without encryption and using Broadcast objects instead of a Pipe and Transport control.

<figure><img src="../.gitbook/assets/broadcast (1).png" alt=""><figcaption><p>Broadcasting Specific Objects</p></figcaption></figure>

The broadcast control implements some related crypto-economic feature. Examples:

* A live broadcaster has to pay for the gas fee and storage, which is wasteful if there is no one listening... one option will be to let DTP stop the writing of the stream on the network until there are enough fund from enough listeners willing to cover, say, the cost of the next 1 minute. DTP handles the automatic "on air" logic and fairly spread the cost among the contributors.
* Listener may choose to tip and message a live talking broadcaster for a special request.

There are some technical challenges particular to broadcasting (See [Future Work](future-work.md#broadcasting-challenges)).\




****
