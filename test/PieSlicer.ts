import { expect } from "chai";
import { ethers } from "hardhat";
const ONE_GWEI = 1_000_000_000;
let pieSlicer;
let creator;
let deployer;
let buyer;
const tokenName = "TokenName";
const tokenSymbol = "TK";

describe("PieSlicer", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.

  describe("Deployment", function () {
    it("Should deploy", async function () {

      [deployer, creator, buyer] =
        await ethers.getSigners();

      const PieSlicer = await ethers.getContractFactory("PieSlicer");
      pieSlicer = await PieSlicer.deploy([], {
        from: deployer,
      });

      await pieSlicer.deployed();
  
      expect(pieSlicer.address).not.to.be.null;
    });
    it("Should deploy an NFT", async function () {
      const events = await (
        await pieSlicer
          .deployPSNFT(tokenName, tokenSymbol, creator.address, ONE_GWEI)
      ).wait();

  
      expect(pieSlicer.address).not.to.be.null;
    });

  });

});
