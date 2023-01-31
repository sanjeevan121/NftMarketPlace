// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


// ERC721 token standard is for non fungible tokens
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// Uniform Resource Identifier -- is a sequence of characters
// that distinguishes one resource from another. 
// It means that the tokenURIs are also stored in "storage". 
// The base implementation in ERC721.sol reads the baseURI in
// memory and concatenates the resulting String on-the-fly,
// without storing them as a state var.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//counters is a utility smart contract used for counting token items in blockchain.
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {

    //using is used for including a
    //library within a contract in solidity.

    using Counters for Counters.Counter;

    //automatically increment _tokenIds which will assign unique Id to individual NFTs
    Counters.Counter private _tokenIds;

    //address of the marketplace that we want to allow our nft to be able to interact with
    //or vice versa
    //we want to allow our nft market to be able to change the ownership
    // of nfts through a separate contarct
    address contractAddress;
    

    //when we deploy this contarct, we need to set the address of the actual marketplace
    constructor(address marketplaceAddress) ERC721("Metaverse Tokens","METT") {
    contractAddress=marketplaceAddress;
    
    }

    //function for minting new tokens
   function createToken(string memory tokenURI) public returns(uint){

    
       _tokenIds.increment();
       uint256 newItemId=_tokenIds.current();

        //mint new tokens, with msg.send as the creator and item id as the item id
        //The _mint() internal function is used to mint a new NFT at the given address.
        // As the function is internal, it can only be used from inherited contracts to mint 
        //new tokens. This function takes the following arguments:

        //to: The address of the owner for whom the new NFT is minted
        //tokenId: The new tokenId for the token that will be minted

        //When you deploy the contract msg.sender is the owner of the contract. 
        //If you have a variable defined in your contract by the name of "owner",
        // you can assign it with the value(address) of msg.sender.

       _mint(msg.sender,newItemId); 
       _setTokenURI(newItemId,tokenURI);

       //gives the marketplace the permission to transact this token between 
       // users from any external contract
       setApprovalForAll(contractAddress,true);
       return newItemId;
       
   } 
}