var SolnSquareVerifier = artifacts.require("./SolnSquareVerifier.sol");
var Verifier = artifacts.require("Verifier");
const verifyZKProof = require("../../zokrates/code/square/proof.json");

contract("TestSolnSquareVerifier", (accounts) => {
  describe("Can Verify ZKSolution and Mint Token", () => {
    const accountOne = accounts[0];
    const accountTwo = accounts[1];

    beforeEach(async () => {
      let verifier = await Verifier.new({ from: accountOne });
      this.contract = await SolnSquareVerifier.new(verifier.address, {
        from: accountOne,
      });
    });

    // Test if a new solution can be added for contract - SolnSquareVerifier
    it("should provide new solution", async () => {
      let result = false;

      try {
        await this.contract.addSolution(
          verifyZKProof.proof.a,
          verifyZKProof.proof.b,
          verifyZKProof.proof.c,
          verifyZKProof.inputs,
          accountTwo,
          1,
          { from: accountTwo }
        );
        result = true;
      } catch (e) {
        console.log(e);
        result = false;
      }
      assert.equal(result, true);
    });

    it("should not be able to mint new token if solution was previously submitted", async () => {
      let result = false;

      try {
        await this.contract.addSolution(
          verifyZKProof.proof.a,
          verifyZKProof.proof.b,
          verifyZKProof.proof.c,
          verifyZKProof.inputs,
          accountTwo,
          1,
          { from: accountTwo }
        );
        await this.contract.addSolution(
          verifyZKProof.proof.a,
          verifyZKProof.proof.b,
          verifyZKProof.proof.c,
          verifyZKProof.inputs,
          accountTwo,
          2,
          { from: accountTwo }
        );
        result = true;
      } catch (e) {
        result = false;
      }
      assert.equal(result, false);
    });

    // Test if an ERC721 token can be minted for contract - SolnSquareVerifier
    it("should be able to mint new token after solution has been submitted", async () => {
      let result = false;
      try {
        await this.contract.addSolution(
          verifyZKProof.proof.a,
          verifyZKProof.proof.b,
          verifyZKProof.proof.c,
          verifyZKProof.inputs,
          accountTwo,
          1,
          { from: accountTwo }
        );
        await this.contract.mintVerifiedSolution(accountTwo, 1, {
          from: accountOne,
        });
        result = true;
      } catch (e) {
        console.log(false);
        result = false;
      }
      assert.equal(result, true);
    });
  });
});
