## Target Audience

Developers should first read the API they intend to use.

This document is for developers curious about DTP inner works.

## At high level, how is the Sui Network used?

Sui owned objects are used for unidirectional data transfer with sub-second latency (See [Simple Transaction](https://docs.sui.io/devnet/learn/how-sui-works#simple-transactions) in Sui docs).

Data Ingress: A data stream is sliced into transactions (txns) and added to the Sui network. The txns are targeted to a destination Pipe (owned object).

Data egress: The data "exit" the network through event streams (emitted by the txns being received at the destination Pipe). The transmitted data can be "observed" by any users, but decoded only by the ones having the decryption key.

The receiving end DTP SDK re-assembles the txns into the original data stream. The stream is then forwarded to the intended end-user (a TCP server, a Rust application layer above etc...).

Slower transactions (Sui consensus) are used for most "control plane" synchronizations.

 
## DTP Glossary

<figure markdown>![](../assets/images/design_terms.png)</figure>

**Client**: An application that initiate a connection.

**Connection:** One connection allows exchanging data between two applications. The applications are localized by their Host object on the Sui network. A connection will start to exchange data only after a Transport Control and one or two Pipe objects are created (for uni or bidirectional transfer respectively).

**Host Object**: Any signature authority that want to transfer data must create its own Host object. This is a Sui shared object involved in many control plane transactions (e.g. creation of a connection). It allows to configure the services (and SLA) that are to be provided, the lifecycle of its associated connections and control the firewall.

**Objects:** Usually refer to Sui objects (See [Sui Docs](https://docs.sui.io/build/programming-with-objects))

**Pipe Object**:All off-chain data exchange involves an intermediate object on the Sui network. This object is the Pipe. It is owned by the sender of the data, and have its event stream observed by the receiver(s). A Pipe is loosely coupled to a Transport or Broadcast Control object for synchronization.

**Server**: Off-chain process intended to respond to client requests.

**Service Level Agreement (SLA)**: Specify the costs, limitations and some behaviors for a service provided by a Host object. Example would be "sent data can be deleted from network storage after 48 hours (2 epochs)". The client signifies that it agrees to an SLA at the time the connection to the node is initiated. The SLA specs are such that DTP can enforce the agreement fairly to all parties.

**Transport Control Object**: Variables and state machines that exists for the lifetime of a single connection. This is a Sui shared object.

## Firewall

<figure markdown>![](../assets/images/ref_firewall.png)</figure>

(1) Gas cost of processing incoming traffic is paid by the sender. That includes connection creation cost and running the firewall at the Pipe Object. Most abuse can therefore be neutralized without requiring any processing/cost from the Server.

Firewall functionality also includes back pressure management to minimize initiating/paying for transactions while the server is already known offline or too busy.

(2) Optionally, the DTP Node Host object gather statistics from all its Pipe objects and adjust the rate limiting rules. This may happen when the Server detects excessive incoming traffic. The gas cost for these likely rare adjustments is to be handled by the Server. (Note: This is a **logical** representation. More details will follow on how this is implemented such that Pipe objects are not involved with slower consensus transactions).

(3) The server configure the firewall and does a periodical heartbeat using its shared DTP Host object. The server may also do some fast detection and control on the firewall (TBD).

(4) When a transaction has no-effect because of the firewall, there is no event emitted (and sender is informed that the transaction was executed, but blocked by the firewall). Therefore, the Server is not impacted.


## Multi-Channel Connection

Data is transmitted as a stream and therefore must be divided into smaller transactions. Even with a fast finality, the bandwidth is limited by the maximum transaction size.

Multiple simple transactions executed in parallel can provide higher bandwidth for a single connection.

Most of the complexity will be in the off-chain end-points when dividing and re-assembling the data stream:

<figure markdown>![](../assets/images/multi_channels.png)</figure>

**Will this be practical?**
There is a lot of cost/performance unknowns with both Sui network and DTP that will probably persist through 2023. DTP architecture is planning for supporting heavy media streaming, but it remains to be seen how practical it will be.

Gas might be expensive and there is some potential limitations about how much Sui fullnodes could scale on a viral broadcast (problem at egress of the network, not with the consensus performance itself).

Light data streaming (<20 Kbps) very likely to be supported and be useful within 2023.

Regardless of practicality, support for multi-channel will be at least useful for demo/stress load on a test network.

Some estimations (See on [Google Sheet](https://docs.google.com/spreadsheets/d/1zBrB1ifhPpnLlsDr6nBN\_N55Kkw9hX06a7EVUpogyn4/edit?usp=sharing)):

<figure markdown>![](../assets/images/multi_channel_est.png)
<mark style="color:red;">(Note: Numbers are best guess as of 11/21/22. Will be revised from time to time)</mark>
</figure>


## High-Availability and Load Balancing

<figure markdown>![](../assets/images/ref_ha.png)<p>Forwarding decision made by Pipe object when multiple end-points (servers) </p></figure>

Off-chain servers can share the incoming load or be each other's fallback for high-availability.

Unlike traditional network, the data is not physically pushed toward a server. Instead, the data remains on the network and an event is emitted about who should "pull it".

It is an off-chain responsibility for the application to subscribe to their respective event stream (with proper identifier filtering) and normally retrieve only its assigned data (this change in some recovery scenario).

Configuration of the end-points and health of the servers is managed through the DTP node, which in turn updates all its pipes and transport control objects.

DTP will hide the high complexity of many race conditions (assignment to a server that died) and connection migrations among all end-points belonging to the same Node.

## Data Deletion

Once the data is confirmed consumed by the receiver(s), then it can be deleted on the L1 network to recover some storage fee <\<Revisit the design needed here once Sui implements Storage fund>>.

The sender of the data can opt out from automated deletion and assume the full storage cost.

Automated deletion is controlled by DTP to provide a fair time for the receiver(s) to consume the data and can be fine tuned through the sender service level agreement (SLA).

The SLAs are published by the server (in its Node object) and one is selected by the client at the time of the connection being established.

## Data Consumption Confirmation

TCP protocol includes acknowledgment of L4 delivery to the destination, but without guarantee of being consumed by the application (requires additional protocol at layer 7).

DTP layer supports both; a confirmation of the data being available on the L1 network (TCP delivery equivalent) and optional confirmation of the client consuming the data (L7 protocol equivalent).

Example of use would be to integrate in the dApps the verification that the data was persisted off-chain by the destination. There is no verification that the destination is honest, but this would be used in context where it would be in the destination best interest to act honestly.

Another benefit for data confirmation is to shorten the time that the data need to be preserved on the network, therefore saving storage fee for the sender.

The "consumed state" is controlled by the receiving application above DTP (the app call a function in the SDK to confirm consumption).

In some use case, the sender may choose to stop transferring further data until the receiver confirm consuming some of the oldest data, therefore motivating the receiver to remain honest. All this will be done under the supervision of DTP for honest handling of the connection service level agreement (SLA).

## Public Broadcasting

Similar to unidirectional, but without encryption and using Broadcast objects instead of a Pipe and Transport control.

<figure><img src="../.gitbook/assets/broadcast (1).png" alt=""><figcaption><p>Broadcasting Specific Objects</p></figcaption></figure>

The broadcast control implements some related crypto-economic feature. Examples:

* A live broadcaster has to pay for the gas fee and storage, which is wasteful if there is no one listening... one option will be to let DTP stop the writing of the stream on the network until there are enough fund from enough listeners willing to cover, say, the cost of the next 1 minute. DTP handles the automatic "on air" logic and fairly spread the cost among the contributors.
* Listener may choose to tip and message a live talking broadcaster for a special request.

There are some technical challenges particular to broadcasting (See [Future Work](future_work.md#broadcasting-challenges)).