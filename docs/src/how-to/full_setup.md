---
editLink: true
headerDepth: 0
---
## Full Development Setup

::: warning
work-in-progress. The installation process is not yet fully implemented.
:::

### (1) Install Suibase
<https://suibase.io/how-to/install>

Suibase allows distinct Sui binaries and keystore management for each network (localnet, devnet, testnet and mainnet).
It also installs the "DTP Services" daemon and "dtp" CLI command for you.

### (2) Enable DTP Services for localnet
Do ```$ localnet enable dtp```

Other useful commands:

- Disable DTP with ```$ localnet disable dtp```
- Update DTP (and Suibase) to latest with ```$ ~/suibase/update```
- Update only the Sui binaries from Mysten Labs with ```$ localnet update```

### (3) Start local processes
Do ```$ localnet start```

It is recommended to develop on a single machine with localnet first and (easily) migrate to testnet later for end-to-end testing.

Note: Localnet runs two instances of the DTP Services on different local port, allowing the simulation of two end-users. This is very convenient for quick development and testing of your own application on a single machine.

Other useful commands:

- Monitor DTP services health (UP/DOWN) with ```$ localnet status```
- Monitor your own services status/account balance with ```$ dtp status```
- Reset the localnet to its genesis state with ```$ localnet regen```

### (4) Optional DTP Self-Test
Do ```$ dtp self-test``` to verify that DTP is working as expected.

You can re-run this command anytime you are trying to isolate if a problem is in your application or the DTP setup itself.


### Next steps (TODO)
-  Instruction to migrate from localnet to testnet testing (should be easy).
-  Tutorial of a simple client/server "echo" service and how testing is done.
