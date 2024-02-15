---
title: Basic Concept
contributors: true
editLink: true
headerDepth: 0
---

Exchange of data through the SUI network can be done between any Web2 application that includes the DTP and Sui SDKs.

Alternatively, the end-users may install the DTP services daemon to handle common cases (e.g making one side of the connection be a JSON-RPC server).

An end-user will first want to establish its own "unique contact point" on the network by creating a "Host Sui Object" using the DTP API.

Note: Most operation done through the DTP API can also be done on the command line with the "dtp" script.

An application can "ping" or "connect" to other Host object created by other apps. Each Host are uniquely identified by a ```<Host Object ID>```.

The typical ```<IP address>:<Port>``` becomes a ```<Host Object ID>:<Port>```

## On-Chain Firewall

For security reason, each Host Object are by default created "completely closed". Using the DTP API, an application can choose to open ports of its Host object to progressively add services.

End-users will be able to observe what an Host allows (or blocks) even before attempting to use the service. An attacker trying to use a non-authorized service will be rejected by the DTP Move package on-chain (no impact on the server at all).

The DTP API supports white/black listing of sender sui address and various traffic policies. Configuration are kept and applied 24/7 on-chain.

## Service Level Agreements (SLA)

DTP provides traditional byte streaming (TCP-Like) connections between Host, but also the simplification of higher level connection, in particular RPC calls.

When configuring a service for your Host, you must choose a "Service Level Agreement" that DTP will enforce.

An example is to require the requester to pay for the cost of the response that your server will have to provide.

::: tip Side Note
This is a good example where adding Web3 qualities to an existing Web2 service creates API monetization without requiring huge security/edge infrastructure investments
:::

DTP defines a set of "Typical" service level agreement to help minimize market confusion. 

| Service Level Agreement     | Who Pays                                                   |
| --------------------------- | ---------------------------------------------------------- |
| DataStream-Balanced         | Everyone pay for their own transactions (txns).            |
| AudioStream-Free            | Broadcaster pays all transaction costs.                    |
| JSON-RPC-Balanced           | Everyone pay for their own txns. Best-effort service.      |
| JSON-RPC-RequesterPaid      | RPC Requester pays. Escrow for success/failure.            |
| JSON-RPC-RequesterPaidPlus  | Same as above, plus the server charges additional fee.     |
| Ping-RequesterPaid          | Ping Requester pays. Escrow for success/failure.           |

The requester agree to the SLA upon creation of the connection and is enforced through DTP escrow for the connection duration. DTP handles the fund redistribution fairly with consideration of various success/failure criteria (more refinement will follow in ~2025).
       
      
       