const { ethers, upgrades } = require("hardhat");

async function main() {
   const gas = await ethers.provider.getGasPrice()
   const PieSlicer = await ethers.getContractFactory("PieSlicer");
   console.log("Deploying Pie Slicer...");
   const pieSlicerContract = await upgrades.deployProxy(PieSlicer, [], {
      gasPrice: gas, 
      initializer: "initialvalue",
   });
   await pieSlicerContract.deployed();
   console.log("Pie Slicer Contract deployed to:", pieSlicerContract.address);
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });