---
editLink: true
---

There are 3 ways to install DTP. 

Choose the one that best fits your needs and you can always later switch from one to the other.

## Choice 1 of 3: Full Development Setup

::: tip This is the only setup available for now.
:::

Recommended if you need any of these:

  * Develop Sui Move package (with or without DTP)
  
  * Develop your own Rust application using DTP and/or Sui Rust SDK.  
  
  * Develop a new type of DTP service (e.g. you want your own backend Rust server process and do not want to use the DTP Services daemon as an intermediate).

The setup includes a Sui development framework (Suibase), the DTP Service Daemon runtime, all the DTP SDKs and some utility scripts for quicker edit/publish/debug development cycles.

DTP is not conflicting with other Sui installations (e.g. official Mysten Labs cargo install) and can be uninstalled easily.

<a href='./full_setup.md?url'><i class='iconfont icon-arrow'></i> Go to Full Setup ...</a>

## Choice 2 of 3: DTP Services Runtime (No Coding)

::: warning Not yet implemented
For now, use the Full Development setup, which includes the DTP Services runtime.
:::

 Choose this setup if you only need one or more of the following feature:

  * Make your existing server API accessible on the Sui network (e.g. REST, JSON-RPC etc...)

  * Make a local directory content accessible on the Sui network (be a "file server")

  * Allow other user on the network to discover and ping your server.  

  * Have end-users (e.g. frontend app) install their own DTP runtime as a local proxy to your backend services.

This setup does not require any coding skills, just configuration in a text file and using the ```dtp``` command line tool.

![](/assets/images/setup_help_services.png?url)


## Choice 3 of 3: DTP Typescript SDK (NPM Packages Only)

::: warning Not yet implemented
The DTP Typescript SDK is not yet written. Priority is to develop the Rust SDK first.
:::

Choose this setup if you only need to develop front-end apps doing DTP connections to existing services and not require the DTP service daemon installation.


