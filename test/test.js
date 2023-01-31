const{expect}=require("chai");
const { ethers } = require("hardhat");




describe("NFTMarket",function(){
    it("Deploy the Smart contracts on blockchain,mint new nfts,sell a NFT and make transactions on the blockchain",async function(){
        const Market= await ethers.getContractFactory("NFTMarket")
        const market= await Market.deploy()
        await market.deployed()


        const marketAddress=market.address
       


        const NFT=await ethers.getContractFactory("NFT")
        const nft=await NFT.deploy(marketAddress)


        await nft.deployed()


        const nftContractAddress=nft.address


        let listingPrice=await market.getListingPrice()
        listingPrice=listingPrice.toString()


        const sellingPrice= ethers.utils.parseUnits("10","ether")
        await nft.createToken("https://www.pwskills1.com")
        await nft.createToken("https://www.pwskills2.com")


        await market.createMarketItem(nftContractAddress,1, sellingPrice,{value:listingPrice})
        await market.createMarketItem(nftContractAddress,2, sellingPrice,{value:listingPrice})
   
   
        const[_,buyerAddress]=await ethers.getSigners()


        await market.connect(buyerAddress).createMarketSale(nftContractAddress,1,{value:sellingPrice})
   
        let items=await market.fetchMarketItems()
        items=await Promise.all(items.map(async i =>{
            const tokenURI=await nft.tokenURI(i.tokenId)
            let item={
                price:i.price.toString(),
                tokenId:i.tokenId.toString(),
                seller:i.seller,
                owner:i.owner,
                tokenURI
            }
            return item
        }))
    console.log('items:',items)
    });
});
