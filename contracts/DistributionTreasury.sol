// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PSNFT} from "./PSNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./PieSlicer.sol";
import "hardhat/console.sol";

contract DistributionTreasury {
    // uint distributionTime;
    PieSlicer pieSlicer;

    constructor(PieSlicer _pieSlicer) {
        // distributionTime = _distributionTime;
        pieSlicer = _pieSlicer;
    }

    event DistributionCompleted(uint totalSlices, uint slice);

    function distributeShares() external {
        address[] memory allOwners = pieSlicer.getHolders();

        uint totalSlices = pieSlicer.totalTokens();
        require(totalSlices > 0, "no nfts sold");

        uint slice = address(this).balance / totalSlices;
        require(slice > 0, "nothing to distribute");
        for (uint i = 0; i < allOwners.length; i++) {
        console.log(slice,pieSlicer.holderBalance(allOwners[i]));

            payable(allOwners[i]).transfer(
                slice * pieSlicer.holderBalance(allOwners[i])
            );
        }

        emit DistributionCompleted(totalSlices, slice);
    }

    receive() external payable {   
    }
}
