---
home: true
icon: home
title: Home
heroImage: assets/images/home_top_capy.png
heroText: ""
tagline: ""
#actions:
#  - text: Install
#    link: /how-to/install.md
#    type: primary

#  - text: Learn More
#    link: /intro.md

  #- text: Docs
  #  link: /guide/

features:
  - title:  Create hybrid dApps
    icon: star-half-stroke
    details: "Decentralized connection control, metering and crypto-economics<br>
    <b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+</b>
    <br>Your existing off-chain services and data."
    link: /

  - title: Security and DDoS Protection
    icon: shield-halved
    details: "<ul style='list-style-type:disc;'>
    <li>Scalable firewall built-in the Sui network!</li>
    <li>Stop DDoS attacks even before it reaches your servers.</li>
    <li>Keep IP addresses hidden (visible only to Sui node operators).</li></ul>
    <a href='examples/rpc_firewall.md'> See firewall example...</a>"
  
    link: /examples/rpc_firewall.md

  - title: Privacy & Authenticity
    icon: user-lock
    details: "<ul style='list-style-type:disc;'>
    <li>On-chain secret exchanges with end-to-end encryption.</li>
    <li>Secured key/certificate installation from centralized servers.</li>
    <li>Authenticity with signed data transfer.</li></ul>"
    link: /

  - title:  Open-Source
    icon: /assets/images/free_icon.svg
    details: "<ul style='list-style-type:disc;'>
    <li>Only code from developers for developers.</li>
    <li>No Token, middlemen, commission or dev fee.</li>
    <li>Only requires smart contracts execution costs (gas fee for Sui transactions).</li></ul>
    <a href='/faq.md'> Check the faq...</a>"
    
    link: /faq.md


  - title:  High Availability
    icon: network-wired
    details: "<ul style='list-style-type:disc;'>
    <li>Automatic failover and/or load balancing among your backend servers.</li>

    <li>Maybe your service would benefit from censorship resistance of the Sui network?</li>
  
    <li>Add serf-like coordination/governance among loosely coupled web2 servers.</li></ul>"
    link: /

  - title: Service Level Agreements
    icon: building-columns
    details: "<ul style='list-style-type:disc;'><li>Add fair Tokenomics to Web2: Pay per request, per byte, per RPC call etc...</li>
    
    <li>Escrow for fair payments depending of success/failure of a query...</li></ul>"
    link: /


---

<img src="/assets/images/total_vs_partial_order_small.PNG?url" style="float: left; padding-right: 20px;"/>

<b> Why Sui and not blockchain 'x' ?</b><br>
SUI has good finality latency stability (low jitter) and network scalability (maintains per connection throughput regardless of total load).<br>

Sui architecture provides two type of transactions:

  * Simple Transaction with sub-second finality for data plane transfer (See 'partial ordering' illustration). This allows fast async/parallel transmission.

  * Narwhal/Bullshark consensus with 2-3 seconds finality used for slower control plane synchronization, like escrow services, reconfiguration, connection creation,etc...


With its flexible dual-type of transactions, Sui makes practical the implementation of common data + control plane design found in IP networks ( [Cloudflare explains it well](https://www.cloudflare.com/learning/network-layer/what-is-the-control-plane/) ).
 
See [How Sui Differs from Other Blockchains?](https://docs.sui.io/learn/sui-compared)

Why not simply use the good old, faster and free internet?

Join the [Discord community](https://discord.gg/Erb6SwsVbH) and let's talk about it!
