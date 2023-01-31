// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    //owner of the nft is the market contract. He will make a commision on every item sold. 
    //you can program all types of diferent ways in which different parties get paid
    //one good way is to charge a listing fee, anyone who uploads a contract pays a listing fee to
    //the owner of the contract so the owner of the contarct gets paid in commision on everyone else's transaction
    address payable owner;
    uint256 listingPrice=0.001 ether;
    constructor() {
        owner=payable(msg.sender);
    }

    struct Marketitem {
        uint itemId;
        address nftContract;
        uint256 tokenId;

        //external account who wants to sell nft on this platform
        address payable seller;

        //owner of nft marketplace portal who gets listing fee
        address payable owner;
        uint256 price;
        bool sold;
    }

    //function definition - mapping(_KeyType => _ValueType)
    //Mapping can only have type of storage and are generally used for state variables.
    //Mappings are mostly used to associate the unique
    //Ethereum address with the associated value type.
    
    mapping(uint256 => Marketitem) private idToMarketItem;



    // An event is an inheritable member of the contract, 
    // which stores the arguments passed in the transaction logs when emitted.
    // Generally, events are used to inform the calling application 
    // about the current state of the contract, with the help of the 
    // logging facility of EVM. Events notify the applications about the change made
    // to the contracts and applications which can be used to execute the dependent logic.
    // Events are defined within the contracts as global and called within its functions. 
    // Events are declared by using the event keyword, followed by an identifier
    // and the parameter list, and ends with a semicolon.
    // The parameter values are used to log the information or for executing
    // the conditional logic. Its information and values are saved as part of
    // the transactions inside the block. There is no need of providing variables,
    // only datatypes are sufficient. An event can be called from any method by using
    // its name and passing the required parameters.

    //There are two types of Solidity event parameters: indexed and not indexed.
    //Blockchain keeps event parameters in transaction logs.
    event MarketItemCreated(

        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;

    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    )
    
    public payable nonReentrant{
       require(price > 0, "Price should at least be 1 wei");
       require(msg.value == listingPrice,"Price must be equal to listing price");

        //require keyword will check if a condition is true and allow code to flow 
        //only if condition is true. If the condition is false, 
        //require will throw an error, the rest of the code will not be executed 
        //and the transaction will revert.

       _itemIds.increment();
       uint256 itemId= _itemIds.current();

       idToMarketItem[itemId] = Marketitem(
           itemId,
           nftContract,
           tokenId,
           payable(msg.sender),
           payable(address(0)),
           price,
           false
       ); 




    
        IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);  

        //this refers to the instance of the contract where the call is made 
        //(you can have multiple instances of the same contract).
        //address(this) refers to the address of the instance of the contract where 
        //the call is being made. msg.sender refers to the address where the contract
        //is being called from.



        //Emit keyword is used to emit an event in solidity, which can be read by the
        //client in Dapp. Event in solidity is to used to log the transactions
        //happening in the blockchain.
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
        
        }
    
    function createMarketSale(
        address nftContract,
        uint256 itemId

        //we dont need to pass the price since the price has been updated in 
        //the state of the smart contract on blockchain when we created the 
        //nft in the previous function i.e function createMarketItem
        
    )   public payable nonReentrant {
        uint price = idToMarketItem[itemId].price;
        uint tokenId=idToMarketItem[itemId].tokenId;
        require(msg.value==price, "Please submit the asking price in order to complete the purchase");
        //if above line is not satisfied then, flow will exit from this function and 
        //current transaction will be reverted

        //transfer crypto into wallet of seller in next line
        idToMarketItem[itemId].seller.transfer(msg.value);

        //in the next line we transfer nft ownership from the seller to buyer
        //the msg.sender is buyer since he is creating the function call which 
        //will be used to buy the nft
        IERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);

        //owner is paying money and status of nft gets updated to sold
        //the sold variable is a state variable and its state is stored in blockchain 
        //and gets updated once secure transaction is made
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold=true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);

    }

    //we are writing a function to fetch all the available nfts
    //this functions return an array of all nfts that can be bought- so that means
    //total nfts minus nfts sold
    //we will use this function on the home page of nft marketplace
    function fetchMarketItems() public view returns (Marketitem[] memory){
        uint itemCount = _itemIds.current();
        uint unsoldItemCount= _itemIds.current() - _itemsSold.current();
        uint currentIndex=0;

        Marketitem[] memory items = new Marketitem[](unsoldItemCount);
        for(uint i=0; i< itemCount;i++){
            if(idToMarketItem[i+1].owner==address(0)){
                uint currentId=idToMarketItem[i+1].itemId;
                Marketitem storage currentItem=idToMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;
            }

        }
            return items;
    }

    //fetch the nfts that you own
    function fetchMyNFTs() public view returns (Marketitem[] memory){
        uint totalItemCount=_itemIds.current();
        uint itemCount=0;
        uint currentIndex=0;

        for (uint i=0;i<totalItemCount;i++)
        {
            if(idToMarketItem[i+1].owner==msg.sender){
                itemCount+=1;
                
                }
        }
            Marketitem[] memory items=new Marketitem[](itemCount);
            for(uint i=0;i<totalItemCount;i++)
            {
                if(idToMarketItem[i+1].owner==msg.sender){
                    uint currentId=i+1;
                    Marketitem storage currentItem = idToMarketItem[currentId];
                    items[currentIndex]=currentItem;
                    currentIndex+=1;


                }
            }
            return items;
    }
    

    //fetch the nfts that you have created
    function fetchItemsCreated() public view returns (Marketitem[] memory){

        uint totalItemCount = _itemIds.current();
        uint itemCount=0;
        uint currentIndex=0;

        for (uint i=0 ; i<totalItemCount ; i++){
            if(idToMarketItem[i+1].seller==msg.sender){
                itemCount+=1;

            }
        }
        Marketitem[] memory items = new Marketitem[](itemCount);
        for(uint i=0;i< totalItemCount; i++){
            if(idToMarketItem[i+1].seller==msg.sender){
                uint currentId=i+1;
                Marketitem storage currentItem= idToMarketItem[currentId];
                items[currentIndex]=currentItem;
                currentIndex+=1;


            }
        }
        return items;
    }


}

