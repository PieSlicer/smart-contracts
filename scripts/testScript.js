const pieSlicer = "0xa5E29c97974Ec63a95c961f4fF4801082BFf45aA";

const { assert } = require("chai");
var ethers = require("ethers");

require("dotenv").config();

var psnftAbi = require("../artifacts/contracts/PSNFT.sol/PSNFT.json").abi;
var pieSlicerAbi = require("../artifacts/contracts/PieSlicer.sol/PieSlicer.json").abi;
var distributionAbi = require("../artifacts/contracts/SqrTreasury.sol/SqrTreasury.json").abi;

const provider = new ethers.providers.JsonRpcProvider(
  "https://rpc.ankr.com/eth_sepolia/"
);

// const phrase = 'laundry taxi conduct love sun picnic taste mushroom economy success horror inflict'

//   const wallet = ethers.Wallet.createRandom();
//   console.log(wallet.address);
//   console.log(wallet.mnemonic);
//   console.log(wallet.privateKey);
// Wallet connected to a provider
// const senderWalletMnemonic = ethers.Wallet.fromMnemonic(
//   process.env.MNEMONIC,
//   "m/44'/60'/0'/0/0"
// );
const senderWallet = new ethers.Wallet(process.env.PK);
let signer = senderWallet.connect(provider);
// console.log(signer.address)


const pieSlicerContract = new ethers.Contract(pieSlicer, pieSlicerAbi, signer);

async function mint(psnftAddress, tokenId) {
const psnftContract = new ethers.Contract(psnftAddress, psnftAbi, signer);

  const a = await psnftContract.mint(
   tokenId
  );

  const b = await a.wait();
  console.log(b);
}

async function getPSNFTs() {
  const nfts = await pieSlicerContract.getNFTContracts();
  console.log("nfts:", nfts);
}
async function test() {
  await getPSNFTs();
//   await mint('0x6D1470823B08aFC6E69efe81A59CDF66244Ab210', 1);
}

test();
