// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PSNFT} from "./PSNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./PieSlicer.sol";

contract DistributionTreasury {
    uint distributionTime;
    PSNFT psNFT;
    PieSlicer pieSlicer;

    constructor(PSNFT _psNFT, uint _distributionTime, PieSlicer _pieSlicer) {
        psNFT = _psNFT;
        distributionTime = _distributionTime;
        pieSlicer = _pieSlicer;
    }

    function distributeShares() external {
        address[] memory nftContracts = pieSlicer.getNFTContracts();
        address[] memory allOwners = pieSlicer.getHolders();

        uint totalSlices = pieSlicer.totalTokens();

        uint slice = address(this).balance / totalSlices;

        for (uint i = 0; i < allOwners.length; i++) {
            uint totalBalance;
            for (uint j = 0; j < nftContracts.length; j++) {
                totalBalance += PSNFT(nftContracts[j]).balanceOf(allOwners[i]);
            }
            payable(allOwners[i]).transfer(
                    slice * psNFT.balanceOf(allOwners[i])
                );
        }
    }

    event MoreSlicesAdded();
    event PieCut();
    event SliceEaten();
}
