var contractInstance = artifacts.require("RLMEstate721Token");

contract("TestERC721Mintable", (accounts) => {
  const accountOne = accounts[0];
  const accountTwo = accounts[1];
  const tokenId = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  describe("match erc721 spec", function () {
    beforeEach(async function () {
      this.contract = await contractInstance.new({ from: accountOne });

      // mint multiple tokens from contract owner account => accountOne

      // First account gets 5 token
      for (let i = 0; i < 5; i++) {
        await this.contract.mint(accountOne, tokenId[i], { from: accountOne });
      }

      // Second account gets 5 token
      for (let i = 5; i < 10; i++) {
        await this.contract.mint(accountTwo, tokenId[i], { from: accountOne });
      }
    });

    it("should return total supply", async function () {
      let result = await this.contract.totalSupply.call();
      assert.equal(tokenId.length, result);
    });

    it("should get token balance", async function () {
      // select random account
      let balanceAccount1 = await this.contract.balanceOf(accountOne);
      assert.equal(5, balanceAccount1);

      let balanceAccount2 = await this.contract.balanceOf(accountTwo);
      assert.equal(5, balanceAccount2);
    });

    // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
    it("should return token URI", async function () {
      let tokenUri = await this.contract.tokenURI.call(tokenId[1]);
      assert.equal(
        `https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/${tokenId[1]}`,
        tokenUri
      );
    });

    it("should transfer token from one owner to another", async function () {
      await this.contract.transferFrom(accountOne, accountTwo, tokenId[2], {
        from: accountOne,
      });

      let result = await this.contract.ownerOf(tokenId[2]);
      assert.equal(accountTwo, result);

      result = await this.contract.balanceOf(accountOne);
      assert.equal(4, result, "[accountOne] does not increment by 1 token");

      result = await this.contract.balanceOf(accountTwo);
      assert.equal(6, result, "[accountTwo] does not decrement by 1 token");

      result = await this.contract.totalSupply.call();
      assert.equal(
        tokenId.length,
        result,
        "[totalSupplyAccount] does not equal the initial addition of the 2 accounts"
      );
    });
  });

  describe("have ownership properties", function () {
    beforeEach(async function () {
      this.contract = await contractInstance.new({ from: accountOne });
    });

    it("should fail when minting when address is not contract owner", async function () {
      let exception = false;
      try {
        await this.contract.mint(accountTwo, 10, { from: accountTwo });
      } catch (e) {
        exception = true;
      }
      assert.equal(exception, true, "[Minting] fails as not contract owner");
    });

    it("should return contract owner", async function () {
      let contractOwner = await this.contract.getContractOwner();
      assert.equal(
        contractOwner,
        accountOne,
        "[Contract] should return contract owner."
      );
    });
  });
});
