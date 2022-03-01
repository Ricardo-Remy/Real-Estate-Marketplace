"use strict";

require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");

const projectId = process.env.PROJECT_ID;
const mnemonic = process.env.MNEMONIC;

// Get SolnSquareVerifier file
const contractSolnSquare = require("./build/contracts/SolnSquareVerifier");

// Read configuration (contract addresses)
const config = require("./config.json");

// Get arguments from node request
const argv = process.argv.slice(2);
const tokenId = argv[0];

(async () => {
  const networkProvider = await new HDWalletProvider(
    mnemonic,
    `wss://rinkeby.infura.io/ws/v3/${projectId}`,
    0
  );
  const web3 = await new Web3(networkProvider);
  const accounts = await web3.eth.getAccounts();
  const contract = await new web3.eth.Contract(
    contractSolnSquare.abi,
    config.SolnSquareVerifier,
    { gasLimit: "4500000" }
  );

  console.log(
    `Total Supply Before Mint: ${(
      await contract.methods.totalSupply().call()
    ).toString()} token`
  );

  const mintToken = {
    accountOwner: accounts[0],
    tokenId: tokenId,
  };
  console.log("New Token Mint:", JSON.stringify(mintToken, null, 2));

  try {
    let resultMint = await contract.methods
      .mint(accounts[0], tokenId)
      .send({ from: accounts[0], gas: 2500000 });

    console.log("resultMint", resultMint);
  } catch (error) {
    console.log("error minting", error);
  }

  console.log(
    `Total supply after Mint: ${(
      await contract.methods.totalSupply().call()
    ).toString()} token`
  );

  process.exit(1);
})();
