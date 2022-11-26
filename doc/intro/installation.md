---
description: '<<TODO : Incomplete. For now, just showing intended dev setups for 2023>>'
---

# Installation

### Local setup for Rust-Apps only development  (Plan for early 2023)

Allows to test data exchange between two local Rust apps on the same development machine.

<figure><img src="../.gitbook/assets/install_1.png" alt=""><figcaption></figcaption></figure>

The Sui network is a **local instance**. It comes with some prefunded accounts for convenience and automation of your tests.\


## Setup with DTP Services Daemon (Plan for April 2023)

Another type of deployment will run a "DTP Services Daemon". The daemon will simplify greatly many use cases.

The daemon provides the bridging to various local applications. A Services Config file specify the features to enable and various TCP or UDP port mapping when applicable.\
\
As an example, this is a setup with only the built-in "File Server" service configured:

<figure><img src="../.gitbook/assets/install_2.png" alt=""><figcaption></figcaption></figure>

The "dtp" CLI tool is the user interface. It communicates with the local daemon to conveniently perform file server operations. \
\
Example to copy a file to a remote location:\
&#x20;   $ dtp cp \<local pathname> \<remote Sui Node address + pathname>"\
\
Another example with cURL reaching a remote server through DTP:

<figure><img src="../.gitbook/assets/install_3.png" alt=""><figcaption></figcaption></figure>

At first, the port mapping will need to be manually specified in the config file, but a more flexible solution will eventually be implemented.\
\
(Note: This config port mapping feature is planned for \~End of August 2023)\
