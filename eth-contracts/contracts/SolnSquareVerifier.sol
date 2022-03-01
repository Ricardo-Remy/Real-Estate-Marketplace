// // SPDX license identifier
pragma solidity ^0.5.2;

// Define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./ERC721Mintable.sol";
import "./SquareVerifier.sol";

// Define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is RLMEstate721Token {
  Verifier private _verifier;

  constructor(address verifierContractAddress) public {
    _verifier = Verifier(verifierContractAddress);
  }

  // Define a solutions struct that can hold an index & an address
  struct Solution {
    uint256 tokenId;
    address accountOwner;
    uint256[2] input;
    bool minted;
  }

  // Define an array of the above struct
  mapping(bytes32 => Solution) solutionsArray;

  // Define a mapping to store unique solutions submitted
  mapping(uint256 => bytes32) private uniqueSubmittedSolution;

  // Create an event to emit when a solution is added
  event AddedSolution(address indexed accountOwner, uint256 indexed tokenId);

  // Modifier to verify solution

  modifier verifySolution(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input
  ) {
    require(
      _verifier.verifyTx(a, b, c, input),
      "[_verifier] not able to verify the provided solution"
    );
    _;
  }

  // Create a function to add the solutions to the array and emit the event
  function addSolution(
    uint256[2] memory a,
    uint256[2][2] memory b,
    uint256[2] memory c,
    uint256[2] memory input,
    address account,
    uint256 tokenId
  ) public verifySolution(a, b, c, input) {
    bytes32 _key = keccak256(abi.encodePacked(a, b, c, input));

    require(
      solutionsArray[_key].tokenId == 0,
      "[solutionsArray] contains already provided solution"
    );

    solutionsArray[_key].input = input;
    solutionsArray[_key].accountOwner = account;
    solutionsArray[_key].tokenId = tokenId;

    uniqueSubmittedSolution[tokenId] = _key;

    // submit event
    emit AddedSolution(account, tokenId);
  }

  // Create a function to mint new NFT only after the solution has been verified
  //  - make sure the solution is unique (has not been used before)
  //  - make sure you handle metadata as well as token supply
  function mintVerifiedSolution(address to, uint256 tokenId)
    public
    returns (bool)
  {
    // generate key
    bytes32 _key = uniqueSubmittedSolution[tokenId];

    // verifysolution is unique
    require(
      _key != bytes32(0),
      "[Solution] - no matching solution for tokenId"
    );

    // verify that token was not minted already
    require(!solutionsArray[_key].minted, "[Token] already minted");

    address accountOwner = solutionsArray[uniqueSubmittedSolution[tokenId]]
      .accountOwner;

    // verify that account owner owns token
    require(accountOwner == to, "[AccountOwner] does not own token");

    solutionsArray[_key].minted = true;

    // return bool for mint
    return super.mint(to, tokenId);
  }
}
