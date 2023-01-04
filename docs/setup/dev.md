---
description: '<<Work-In-Progress: Showing intended dev setups for 2023>>'
---

# Installation

### Localnet setup for Rust-Apps only development  (Plan for early 2023)

Allows to test data exchange between two local Rust apps on the same development machine.

<figure><img src="../.gitbook/assets/install_1.png" alt=""><figcaption></figcaption></figure>

The Sui network is a **localnet instance**. It comes with prefunded client accounts for convenience and automation of your tests.\
\
You can have the localnet running minutes after cloning the DTP repo. \
\
See the 'init-localnet' script:\
&#x20;            [https://github.com/mario4tier/dtp/tree/main/script](https://github.com/mario4tier/dtp/tree/main/script)

## Setup with the DTP Services Daemon (Plan for April 2023)

A common type of deployment will run the "DTP Services Daemon". This setup simplifies many use cases.

The daemon provides the bridging to various local applications. A Services Config file specify the enabled features and various port mapping (when applicable).\
\
As an example, this is the built-in "File Server":

<figure><img src="../.gitbook/assets/FTP_Daemon_012023.png" alt=""><figcaption></figcaption></figure>

The "dtp" CLI tool is the user interface. It communicates with the local daemon to perform file server operations. \
\
Example to copy a file to a remote location:\
&#x20;   $ dtp cp \<local pathname> \<remote Sui Host Object ID + pathname>"\
\
Another example with cURL reaching a remote object ID through DTP:

<figure><img src="../.gitbook/assets/RPC_Daemon_012023.png" alt=""><figcaption></figcaption></figure>

At first, the port mapping will need to be manually specified in the config file, but a more flexible solution will eventually be implemented.\
\
(Note: This config port mapping feature is planned for \~End of August 2023)\