const hre=require("hardhat");

async function main() {
 
  const NFTMarket = await ethers.getContractFactory("NFTMarket");
  const nftMarket = await NFTMarket.deploy();

  await nftMarket.deployed();

  console.log("nft market deployed to:", nftMarket.address);

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nftMarket.address);
  await nft.deployed();

  console.log("nft deployed to :",nft.address)
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
