var Verifier = artifacts.require("./Verifier.sol");
var RLMEstate721Token = artifacts.require("RLMEstate721Token");
var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");

module.exports = async function (deployer) {
  await deployer.deploy(RLMEstate721Token);
  await deployer.deploy(Verifier);
  await deployer.deploy(SolnSquareVerifier, Verifier.address);
};
