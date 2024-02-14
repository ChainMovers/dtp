---
editLink: true
---

# Rust Development Setup Installation

### Follow the Sui installation
<https://docs.sui.io/build/install#prerequisites>

### Clone DTP
<https://github.com/mario4tier/dtp>


### Initialize localnet 

Just run the DTP "init-localnet" and it will initialize the whole DTP setup and (re)start the "sui" localnet process as needed. 

The localnet will be re-initialized with always the same configuration, address and funding.
(it uses its own configuration file at genesis for a deterministic setup).

From this point use "lsui" and "dsui" shell scripts (as a direct replacement of "sui") to access localnet and devnet respectively.

Output example:
``` text
~/dtp$ ./dtp/script/init-localnet
Output location = /home/user/dtp-dev
Stopping running localnet (sui process pid 1317)
Building localnet using latest Sui devnet branch...
    Finished dev [unoptimized + debuginfo] target(s) in 1.29s
Removing existing /home/user/dtp-dev/localnet directory
Starting new localnet process (may take up to 30 secs)
.........
New localnet started (sui 0.20.0, process pid 6798)
========
localnet => http://0.0.0.0:9000 (active)
devnet => https://fullnode.devnet.sui.io:443
========
All addresses with coins:
Showing 5 results.
0x267d4904898cbc15f165a18541154ec8c5732fcb
0x68db58b41d97e4cf1ea7d9327036ebd306a7930a
0x99d821380348ee02dd685a3af6d7123d92db0d3c
0xbbd8d0695c369b04e9207fca4ef9f5f15b2c0de7
0xe7f134729591f52cf0638c2500a7ed228033a9e7
========
All coins owned by 0xe7f134729591f52cf0638c2500a7ed228033a9e7 (active):
                 Object ID                  |  Gas Value
----------------------------------------------------------------------
 0x0b162ef4f83118cc0ad811de35ed330ec3441d7b | 100000000000000
 0x2d43245a6af1f65847f7c18d5f6aabbd8e11299b | 100000000000000
 0x9811c29f1dadb67aadcd59c75693b4a91b347fbb | 100000000000000
 0xc8381677d3c213f9b0e9ef3d2d14051458b6af8a | 100000000000000
 0xd0b2b2227244707bce233d13bf537af7a6710c01 | 100000000000000
========

Remember:
  Use "dsui" to access devnet
  Use "lsui" to access your localnet

Success. Try it by typing "lsui client gas"
host:~/$
```

### Publish DTP Package (localnet)
~/dtp$ publish-localnet


### Run DTP Integration Test (localnet)
~/dtp$ cargo test

When running integration tests, the test setup makes sure a localnet (sui process) and a peer DTP service Daemon (dtp process) simulate interacting with a remote peer.

This allows to automate your own client/server integration test of your own application on a single machine (Just need to make sure to use a different set of object coin, client address and localhost:port. More on this later).
  