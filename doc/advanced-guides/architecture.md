---
description: <<Work in progress. High level for now, exhaustive RFC/specs later>>
---

# Architecture

## **Should you read the architecture document?**

Developers should start with the API documentation of the SDK, and come to this document only if curious on the inner workings.

This architecture document is intended to coordinate among developers modifying DTP itself.

## DTP Connection Types

At functional level, DTP is similar to TCP but differ significantly in its implementation to benefit from what is already provided by the L1 network.

There are mainly two type of DTP connections:

* Bidirectional : Connection-oriented (like TCP)
* Unidirectional: Also connection-oriented (e.g. for encryption), but heavy data can flow only in one direction.

DTP data is originated using Sui transactions (instead of "packets").\
The data is received through event streams.

## DTP Address

The typical \<IP address>:\<Port> becomes a \<Node Sui Address>:\<Protocol Sui address>\
\
Anyone can create a new "protocol port".\
\
To user, DTP address could look like "acme.com:80", "myradio:channel\_6".

DNS is provided for both Node and Protocol Sui address (a node can choose to designate a default protocol in DNS).\
\
Most standard IP service name and protocol port less than 65536 are reserved to minimize confusion ( [IANA- Service Name and Transport Protocol Port Registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml) )\


## Terminologies

<figure><img src="../.gitbook/assets/terminology_connections (1).png" alt=""><figcaption><p>Example of two connections between 3 end-users</p></figcaption></figure>

**Objects:** Usually refer to on-chain Sui objects ( See [Sui Docs](https://docs.sui.io/build/programming-with-objects) )\
\
**End-User**: A signature authority that can send/receive data.

**Connection:** One connection allows to exchange data between two end-users. Can be uni or bi-directional. An end-user create a connection by calling a function into the destination DTP Node object program (TBD Connection API).\
\
**End-Point**: An off-chain process that can receive data from other end-points. An end point can handle multiple local end users, protocols and connections simultaneously (each independently encrypted).

**Node Object**: Any end-user that want to receive or send data must create its own Node object. The node object is configured to allow/block the services that your app needs. Nodes allows others to find and access your services, including returning data in a bi-directional connection.\
Nodes also allow to control the firewall settings.

**Client**: End-point initiating a bi-directional connection with a Node.

**Server**: End-point assigned to respond to client requests.

**Pipe Object**: Exist for every direction of a connection. It is the object used to transfer data after a connection is created. End-points cannot talk to each other directly, they always need to go through a Sui network object. A pipe can from time to time change the endpoint for high-availability or load balancing (if the end-user have configured multiple end-point to its Node). Notice that even if a Pipe can have multiple end-points, they must all be for the same end-user.\


**Transport Params Object**: Configuration and reference to objects that never changes for the lifetime of a single connection. Created and own by the DTP Node object. \
\
**Transport Control Object**: Variables and state machines that exists and changes for the lifetime of a single connection. Created and own by the DTP Node object.\
\
**Outlet:** Similar to pipe object, but without an endpoint or transport object. Intended for broadcast and multicast application. \


## Uni-directional Connection

<figure><img src="../.gitbook/assets/unidirectional_connection.png" alt=""><figcaption><p>Uni-Directional Connection. One direction data plane, but still bi-directional control plane.</p></figcaption></figure>

Pipe object are unidirectional for the data transfer (two needed for a bi-directional connection).\
\
Although the data is intended to flow in one direction, some lightweight bi-directional exchanges still happens at various point:\
\
(1) When the connection is created, some bi-directional exchange can happen between the source end-point and the destination DTP Node object.\
\
(2) Exchange between end-points through the "Transport Control Object". This relate to encryption protocols (done once or periodic) for ultimately allowing the destination to validate/decode the received data.

(3) Pipe are not **purely** unidirectional. Sender interactions with a Pipe are done with transactions, which means return values allows some responses in failure cases (e.g. the data was immediately dropped by the Pipe because of a receiver firewall rule).

## End-point High-Availability and Load Balancing

<figure><img src="../.gitbook/assets/load_balancing_1 (1).png" alt=""><figcaption><p>Forwarding decision made by Pipe object when multiple end-points (servers) </p></figcaption></figure>

Off-chain servers can share the incoming load or be each others fallback for high-availability.

Unlike traditional network, the data is not physically forwarded toward a server. Instead, the data remains on the network and an event is emitted toward who should "pick it up".\
\
The receiving Pipe object is therefore only responsible to emit an event. It is an off-chain responsibility for the DTP daemons to subscribe to their respective event stream (with proper identifier filtering) and normally retrieve only its assigned data (which is ignored in some recovery scenario).\
\
Configuration of the end-points and liveness of the DTP daemons is managed through the DTP node, which in turn updates all its Pipes/connections for the latest health reports.\
\
DTP will hide the complexity of race conditions (assignment to a server that died). In particular, the Pipe object keeps track if at least one end-points did confirm the consumption of the streamed event.\
\
Once some data is confirmed consumed, the L1 network is no longer responsible for persistence (broadcast/multicast handled differently). Therefore, the end-point should make sure that it is \*completely\* done with the data (or reliably persisted) before confirming its consumption, since DTP does not provide a retry mechanism.\
\
One advantage of DTP compared to TCP, is that the notion of reliable transport can extend at L7 (application level). That is, the application can choose to confirm that the data was more than just transported, but also fully processed.\


## **Broadcasting/Multicasting Encryption**

The broadcasted data can be independently consumed by anyone subscribing to the outlet event stream. Only the user with the decryption key will be able to make sense of the data. The distribution of the decryption key is a responsibility left to the dApps. More research to be done here how DTP could one day mitigate (impossible to eliminate) key sharing/piracy problems \[1]\[2]**.**\
****\
****\[1] Wikipedia [Broadcast Encryption](https://en.wikipedia.org/wiki/Broadcast\_encryption) \
\[2] Wikipedia [Multicast Encryption](https://en.wikipedia.org/wiki/Multicast\_encryption)
