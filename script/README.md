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

## Verify the Sui localnet is running on your machine
Do the following
```
$ pgrep sui
1773
```
This is the PID. If a number is shown, the sui process is running, meaning the localnet is running.

TODO Add a simple cURL to confirm port open.

## Initial State
Always same 5 client addresses. The 0xc7148~89a7 is the default active client and will be funded with 5 object coins.

```
$ lsui client addresses
Showing 5 results.
0x4e8b8c06d7aed3c11195794fa7b0469855c57b30
0x5f11df8d90fef7a642d561aed0f2ee64de5c373c
0x8638a4d6438b399a77659463a25fdf2bdf0b229b
0x86f066b23d7e60ec4dbb280a4c265772c186693b
0xc7148f0c0086adf172eb4c2076c7d888337789a7

$ lsui client active-address
0xc7148f0c0086adf172eb4c2076c7d888337789a7

$ lsui client gas
                 Object ID                  |  Gas Value
----------------------------------------------------------------------
 0x0b162ef4f83118cc0ad811de35ed330ec3441d7b | 100000000000000
 0x2d43245a6af1f65847f7c18d5f6aabbd8e11299b | 100000000000000
 0x9811c29f1dadb67aadcd59c75693b4a91b347fbb | 100000000000000
 0xc8381677d3c213f9b0e9ef3d2d14051458b6af8a | 100000000000000
 0xd0b2b2227244707bce233d13bf537af7a6710c01 | 100000000000000
```

## Development Setup
 ```
 <your directory>
       │
       ├── dtp/           # The git cloned dtp
       |   ├── ...
       │   └── script/
       │       ├── init-localnet # Creates dtp-dev/sui-devnet and dtp-dev/localnet
       │       ├── lsui          # Sui CLI frontend for localnet (devnet branch)
       │       ├── dsui          # Sui CLI frontend for live devnet (TODO)
       │       └── tsui          # Sui CLI frontend for live testnet (TODO)
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

