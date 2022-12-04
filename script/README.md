After a git clone of dtp, please use these scripts to develop with a convenient and more deterministic setup.

**Features:**
  - Keeps localnet/devnet/testnet/mainnet keystores seperated.
  - Does not touch the user level ~/.sui and its keystore (assumes might be used later when mainnet).
  - Creates a self-contain and deterministic localnet that can be re-initialized with the same pre-funded address.
  - Sui CLI frontends that target specific network (e.g. "dsui client gas" will be for the live devnet).
  - Creates Sui local repos (devnet and main branches). Makes Rust app development more efficient.

 ```
 <your directory>
       │
       ├── dtp/           # The git cloned dtp
       |   ├── ...
       │   └── script/
       │       ├── init-localnet  # Creates dtp-dev/sui-devnet and dtp-dev/localnet
       │       ├── lsui           # Sui CLI for localnet.
       │       ├── dsui           # Sui CLI for live devnet
       │       └── tsui           # Sui CLI for live testnet
       │       
       └── dtp-dev/       # Created by the scripts
           ├── sui-devnet         # Complete local repo of Sui devnet branch.
           ├── sui-main           # Complete local repo of Sui main branch.
           ├── localnet           # All localnet files, running at http://0.0.0.0:9000
           ├── devnet             # Keystore for live devnet network
           └── testnet            # Keystore for live tesnet network
```
