import { HardhatUserConfig } from "hardhat/config";
// import "@openzeppelin/hardhat-upgrades";

require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("hardhat-contract-sizer");
require("@nomicfoundation/hardhat-foundry");
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: `https://rpc.sepolia.org`,
      accounts: [process.env.PK as string]
    }
  }
};

export default config;
