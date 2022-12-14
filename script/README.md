Consider using these scripts for a deterministic development setup using a localnet.

## Not sure where to start?
Try this:
  1. Clone this repo
  2. Run 'init-localnet' located in 'dtp/script'. It will download and initialize everything.
  3. Verify the localnet is running and is as expected (see 'Initial State' below).
  4. Develop your app. Localnet will be at http://0.0.0.0:9000
  5. Run 'init-localnet' anytime to reset the localnet to its initial state.

## Features
  - Keeps localnet/devnet/testnet/mainnet keystores seperated.
  - Does not touch the user level ~/.sui and its keystore (assumes might be used for mainnet).
  - Creates self-contain and deterministic localnet that can be re-initialized with the same pre-funded address.
  - Sui CLI frontends that target specific network (e.g. "dsui client gas" will be for the live devnet).

## Initial State
Always same 3 client addresses. The 0xcfed~46ba2 is the default active client and will be funded with 5 object coins.
```
$ lsui client addresses
Showing 3 results.
0x109f6827f048f19d0b7e75a63066543d82a1ae6b
0x9ae6d40296ddb5c97ed0b095270b1ff6f72c2ef9
0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2

$ lsui client active-address
0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2

$ lsui client gas
                 Object ID                  |  Gas Value
----------------------------------------------------------------------
 0x6205fc058b205227d7b7bd5b4e7802f0055157c6 | 100000000000000
 0xb2c64298dd42e83725fe991724a27741abb3aa2f | 100000000000000
 0xb49fe4af8d317d442e228d7d97896de9f7f5ef9e | 100000000000000
 0xdda7a05332162389586c18c4c518c9811293cb09 | 100000000000000
 0xef7d5e8fe9b133c431b386f27b17d4aaaa55e58b | 100000000000000
```

## Development Setup
 ```
 <your directory>
       │
       ├── dtp/           # The git cloned dtp
       |   ├── ...
       │   └── script/
       │       ├── init-localnet # Creates dtp-dev/sui-devnet and localnet-devnet
       │       ├── lsui          # Sui CLI for localnet (devnet branch)
       │       ├── dsui          # Sui CLI for live devnet
       │       └── tsui          # Sui CLI for live testnet
       │       
       └── dtp-dev/       # Created by the scripts
           ├── sui-devnet         # Complete local repo of Sui devnet branch.
           ├── localnet           # All localnet files, devnet branch runs at http://0.0.0.0:9000
           ├── devnet             # Keystore for live devnet network
           └── testnet            # Keystore for live tesnet network
```

init-localnet fetch&build latest devnet from the Sui repo, create the localnet from scratch and (re)start the sui daemon.

The first init-localnet execution will be long (many minutes to compile everything), but subsequent calls are fast (~10 seconds).

# Example localnet call with sui-sdk (Rust)
```
use std::str::FromStr;
use sui_sdk::types::base_types::SuiAddress;
use sui_sdk::SuiClient;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // Test localnet with the pre-funded wallet.
    let sui = SuiClient::new("http://0.0.0.0:9000", None, None).await?;
    let address = SuiAddress::from_str("0xcfed50a652b8fce7a7917a8a736a7c2b1d646ba2")?;
    let objects = sui.read_api().get_objects_owned_by_address(address).await?;
    println!("{:?}", objects);
    Ok(())
}

