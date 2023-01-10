# JSON-RPC Firewall

In this example, a Web3 application access a Web2 server providing a JSON-RPC API to its customer. 

One of the goal is to protect the Web2 server from DDoS attack, in particular, hide its IP address.

<figure markdown>![](../assets/images/example_rpc_firewall.png)</figure>

A DTP "Services Daemon" runs as a TCP/IP proxy on the same machine as the web2 server.

Since the sender has to pay for all the data byte transmission costs through the Sui network, an attack is costly and mostly futile.

The server IP address is visible only to the Sui nodes (not to the Web3 users on the other side of the Sui network). This mitigates direct traditional IP attacks. The server is not completely hidden, but the owner can control its Sui node partners (in similar way that one choose to, say, trust a reputable company such as Cloudflare).

On the drawing, everything in green and blue is provided by DTP and the Sui infrastructure respectively. The application developer provides only what is shown in yellow.

In this example the Web3 app contact the hidden web2 IP server using the `#!Rust <Host Object ID>`:8923 address and DTP takes care of the safe data transfer.

!!! tip "Work-In-Progress... there is more to it... such as mitigation with dynamic `#!Rust <Host ObjectID>` to more than one origin IP mapping"