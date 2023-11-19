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

      [deployer, creator, buyer, buyer1, buyer2] =
        await ethers.getSigners();

      const PieSlicer = await ethers.getContractFactory("PieSlicer");

      pieSlicer = await PieSlicer.deploy();

      await pieSlicer.deployed();

      expect(pieSlicer.address).not.to.be.null;
      const distributor = await pieSlicer.distributionTreasury();
      const we = await ethers.provider.getBalance(distributor);
      console.log(we);

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
      const tx = await psnft.connect(buyer).mint(1, { value: ONE_GWEI });
      const a = await tx.wait();

      const balance = await psnft.balanceOf(buyer.address);
      expect(balance.toString()).to.eq("1");

      const slices = await pieSlicer.totalTokens();
      expect(slices.toString()).to.eq("1");


      const holderBalance = await pieSlicer.holderBalance(buyer.address);
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
      expect(balance.toString()).to.eq("2");

      const slices = await pieSlicer.totalTokens();
      expect(slices.toString()).to.eq("2");


      const holderBalance = await pieSlicer.holderBalance(buyer.address);
      expect(holderBalance.toString()).to.eq("2");

    });

    it("Should mint more NFTs", async function () {
      const nftAddresses = await pieSlicer.getNFTContracts();
      const nftAddress = nftAddresses[0];

      const PSNFT = await ethers.getContractFactory("PSNFT");
      const psnft = PSNFT.attach(nftAddress);

      const distributor = await psnft.ditrbutionTreasury();
      await (await psnft.connect(buyer).mint(3, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer1).mint(4, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer1).mint(5, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer2).mint(6, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer2).mint(7, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer2).mint(8, { value: ONE_GWEI })).wait();
      await (await psnft.connect(buyer2).mint(9, { value: ONE_GWEI })).wait();


      const balance = await psnft.balanceOf(buyer.address);
      expect(balance.toString()).to.eq("3");

      const slices = await pieSlicer.totalTokens();
      expect(slices.toString()).to.eq("9");


      const holderBalance = await pieSlicer.holderBalance(buyer.address);
      expect(holderBalance.toString()).to.eq("3");

      const tokenUri = await psnft.tokenURI(1);
      expect(tokenUri).to.eq('ipfs://bafybeieslvbdtrq7rxwvrxfbmqu7thqlup2xdfhwt7ac7w4heqvk4vm52y/1.json');
    });

    it("Should distribute funds", async function () {

      const distributor = await pieSlicer.distributionTreasury();

      const distributorBefore = await ethers.provider.getBalance(distributor);
      console.log('treasury distribution before: ', distributorBefore.toString());


      const DistributionTreasury = await ethers.getContractFactory("DistributionTreasury");
      const distributionTreasury = DistributionTreasury.attach(distributor);
      const buyerBefore1 = await ethers.provider.getBalance(buyer.address);
      console.log('user 1 balance before: ', buyerBefore1.toString());

      const buyerBefore2 = await ethers.provider.getBalance(buyer1.address);
      console.log('user 2 balance before: ', buyerBefore2.toString());

      const buyerBefore3 = await ethers.provider.getBalance(buyer2.address);
      console.log('user 3 balance before: ', buyerBefore3.toString());

      const events = await( await distributionTreasury.distributeShares()).wait();
      // console.log(events);

      const buyerAfter1 = await ethers.provider.getBalance(buyer.address);
      console.log('user 1 balance after:  ', buyerAfter1.toString());

      const buyerAfter2 = await ethers.provider.getBalance(buyer1.address);
      console.log('user 2 balance after:  ', buyerAfter2.toString());
      
      const buyerAfter3 = await ethers.provider.getBalance(buyer2.address);
      console.log('user 3 balance after:  ', buyerAfter3.toString());


      const treasuryAfter = await ethers.provider.getBalance(distributor);
      console.log('treasury distribution after: ', treasuryAfter.toString());

      console.log('user 1 reward: ', buyerAfter1 - buyerBefore1);
      console.log('user 2 reward: ', buyerAfter2 - buyerBefore2);
      console.log('user 3 reward: ', buyerAfter3 - buyerBefore3);

    });
  });
});


