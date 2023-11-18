import { expect } from "chai";
import { ethers } from "hardhat";
const ONE_GWEI = 1_000_000_000;
let pieSlicer;
let creator;
let deployer;
let buyer;
let buyer1;
let buyer2;
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

      pieSlicer = await PieSlicer.deploy();

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

    it("Should mint an NFT", async function () {
      const nftAddresses = await pieSlicer.getNFTContracts();
      const nftAddress = nftAddresses[0];

      const PSNFT = await ethers.getContractFactory("PSNFT");
      const psnft = PSNFT.attach(nftAddress);

      const distributor = await psnft.ditrbutionTreasury();
      const tx = await psnft.mint(1, { value: ONE_GWEI });
      const a = await tx.wait();

      const balance = await psnft.balanceOf(deployer.address);
      expect(balance.toString()).to.eq("1");

      const slices = await pieSlicer.totalTokens();
      expect(slices.toString()).to.eq("1");


      const holderBalance = await pieSlicer.holderBalance(deployer.address);
      expect(holderBalance.toString()).to.eq("1");

    });

    it("Should mint more NFTs", async function () {
      const nftAddresses = await pieSlicer.getNFTContracts();
      const nftAddress = nftAddresses[0];

      const PSNFT = await ethers.getContractFactory("PSNFT");
      const psnft = PSNFT.attach(nftAddress);

      const distributor = await psnft.ditrbutionTreasury();
      const tx = await psnft.connect(buyer).mint(2, { value: ONE_GWEI });
      const a = await tx.wait();

      const balance = await psnft.balanceOf(buyer.address);
      expect(balance.toString()).to.eq("1");

      const slices = await pieSlicer.totalTokens();
      expect(slices.toString()).to.eq("2");


      const holderBalance = await pieSlicer.holderBalance(buyer.address);
      expect(holderBalance.toString()).to.eq("1");

    });
  });

});
