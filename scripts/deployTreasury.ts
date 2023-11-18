const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const DistributionTreasury = await ethers.getContractFactory("DistributionTreasury");
   console.log("Deploying Pie Slicer...");
   const distTreasury = await DistributionTreasury.deploy('0xD7CE752B7afFCA998a3A493D2ED59f4bf9251e7c');
   await distTreasury.deployed();
   console.log("distTreasury Contract deployed to:", distTreasury.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });