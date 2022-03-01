"use strict";

require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");

const projectId = process.env.PROJECT_ID;
const mnemonic = process.env.MNEMONIC;

// Get verifier file
const contractSolnSquare = require("./build/contracts/SolnSquareVerifier");

// Read configuration (contract addresses)
const config = require("./config.json");

// Get arguments from node request
const argv = process.argv.slice(2);
const proofContract = require(argv[0]);
const tokenId = argv[1];

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

  const solutionProvided = {
    proofA: proofContract.proof.a,
    proofB: proofContract.proof.b,
    proofC: proofContract.proof.c,
    proofInput: proofContract.inputs,
    accountOwner: accounts[0],
    tokenId: tokenId,
  };

  console.log("solutionProvided", solutionProvided);

  console.log(JSON.stringify(solutionProvided, null, 2));

  try {
    let solution = await contract.methods
      .addSolution(
        proofContract.proof.a,
        proofContract.proof.b,
        proofContract.proof.c,
        proofContract.inputs,
        accounts[0],
        tokenId
      )
      .send({ from: accounts[0], gas: 4500000 });

    console.log("solution", solution);
    return solution;
  } catch (error) {
    console.log("error resultAddSolution", error);
  }

  process.exit(1);
})();
