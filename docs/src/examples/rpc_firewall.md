---
editLink: true
---
# JSON-RPC Firewall

In this example, a company want to provide a JSON-RPC API service to its customer front-end applications.

One goal is to protect the web2 server from DDoS attack, in particular, hide the IP address.

![](/assets/images/example_rpc_firewall.png?url)

A DTP Services Daemon runs as a TCP/IP proxy on the same machine as the web2 server.

Since the sender has to pay for all the data byte transmission costs through the Sui network, an attack is costly and mostly futile.

The server IP address is visible only to the Sui nodes (not to the users on the other side of the Sui network). This mitigates traditional direct IP attacks. 

In this example the frontend contact the hidden web2 IP server using the ```<Host Object ID>:8923``` address and DTP takes care of the safe data transfer.

On the drawing, everything in green and blue is provided by DTP and the Sui infrastructure respectively. The application developer provides only what is shown in yellow.

::: warning Is the DDoS protection 100% secure?
It depends... the server operator need to have some faith that its Sui node partners are honest (in similar way that one choose to trust a reputable company such as Cloudflare). To mitigate this, a company may choose to run their own Sui fullnodes, making their servers IP addresses near impossible to target by anyone.
:::

::: tip Scalability and Reliability
DTP also supports having a single Host Object ID be resolved to more than one backend servers (failover, load-balancing...). This is done through DTP Services configuration.
:::