# Udacity Blockchain Capstone - Real Estate Market Project

The capstone will build upon the knowledge you have gained in the course in order to build a decentralized housing product.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle).
Please make sure you have also metamask installed.

## Tech stack

```
Truffle v5.4.28 (core: 5.4.28)
Solidity v0.5.16 (solc-js)
Node v12.13.0
Web3.js v1.5.3
```

## How to install and run the project

### Repo

To install, download or clone the repo, then:

```
npm install
```

## Truffle develop

Once Zokrates files generated, run the following commands in the truffle console:

```
cd eth-contracts
```

```
truffle develop
```

Once in the develop console run the following commands in this order:

```
compile
```

```
migrate --reset
```

```
test
```

The 11 tests should pass and fulfill the acceptance criterias.

## Zero Knowledge - Zokrates

To avoid everyone being able to mint on demand, we have implemented a ZK proof together with Zokrates. Before minting a new token, the contract owner needs to add a solution that will be verified by a proof and witness. To achieve that, run the following commands as per the [acceptance criterias](https://classroom.udacity.com/nanodegrees/nd1309/parts/96a40469-83f5-47ff-bcb1-faf42f327320/modules/79892caa-fad4-421b-937f-67b7fdf87a77/lessons/e3cbd30f-a202-4379-977d-f38453a2d256/concepts/eda557f7-dde3-4152-96e7-f8ea8fb04d34).

## Deploy the contract - rinkeby network

To deploy your contract to the testnetwork run the following command:

```
cd eth-contracts
```

Don't forget to create your .env file inside the eth-contrats folder.
You should add your MNEMONIC and PROJECT_ID.

```
truffle migrate --reset --network rinkeby
```

Once your project deployed, you want to submit a solution before minting a token.

Make sure to change your config.json in eth-contracts that matches your deployed contracts.

Once done, run the following command:

```
cd eth-contracts
```

```
node addSolution.js ../zokrates/code/square/proof.json 0
```

This will add a solution for first tokenId 0.
You should reveive an Event in the console mentioning that you added a solution.
Once achieved, we finally want to mint the token with the correct id. In this case tokenId 0.

```
node mintVerifiedSolution.js 0
```

## Project outcome

Below you will find fulfilled requirements according to the acceptance criterias:

The contract ABI can be found under:

```
eth-contracts/build/contracts
```

NB: In order to see how the project interacts with the contract ABI, you can have a look at how the following file scripts are using it:

```
addSolution.js
```

and

```
mintVerifiedSolution.js
```

The contracts:

```
RLMEstate721Token
---
> transaction hash: 0x92de99b63356b6e3bd1dd5513577aab7ab8f3d71b067f5cdcf305ab561092e9c
> contract address: 0x28b6Dc785936c2D4a6787eac0cE628BDA0e98473
> account: 0xE119b11A240758deEceaD6Aa0a42C70419d919Ff
```

```
Verifier
---
> transaction hash: 0x1bbcc8f724e548bd3fe74deb61e7ebc9a39ecd80e0fd5636b26ed3b3b498857c
> contract address: 0x54497A52186F1a57530273EbA766785A68BD1A20
> account: 0xE119b11A240758deEceaD6Aa0a42C70419d919Ff
```

```
"SolnSquareVerifier"
---
> transaction hash: 0xa6c6da2b5ebc562967259efde2fb3ee675d1c59013c6048f2feeffa3654ab3e4
> contract address: 0x78F8072F0Cb34753cBe953cc4FC519B5613DbC30
> account: 0xE119b11A240758deEceaD6Aa0a42C70419d919Ff
```

The contract owner minted 10 tokens:

```
https://rinkeby.etherscan.io/address/0x78F8072F0Cb34753cBe953cc4FC519B5613DbC30
```

Opensea seller - listed 5 tokens for sell:

```
https://testnets.opensea.io/0xe119b11a240758deecead6aa0a42c70419d919ff
```

Opensea suyer - bought 5 tokens from the seller:

```
https://testnets.opensea.io/0xaab58cd5ee7a364eb446a8158ada895e5a4d576c
```

## Resources

- [Remix - Solidity IDE](https://remix.ethereum.org/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Truffle Framework](https://truffleframework.com/)
- [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
- [Open Zeppelin ](https://openzeppelin.org/)
- [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
- [Docker](https://docs.docker.com/install/)
- [ZoKrates](https://github.com/Zokrates/ZoKrates)
