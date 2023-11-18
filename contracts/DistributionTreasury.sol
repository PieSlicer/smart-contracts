// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {PSNFT} from "./PSNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./PieSlicer.sol";
import "hardhat/console.sol";

contract DistributionTreasury {
    uint public distributionTime;
    PieSlicer pieSlicer;

    // todo: set distribution time differently;
    constructor(PieSlicer _pieSlicer) {
        distributionTime = block.timestamp + 86400;
        pieSlicer = _pieSlicer;
    }

    event DistributionCompleted(uint totalSlices, uint slice);

    // todo: add check for time of distribution
    function distributeShares() external {
        address[] memory allOwners = pieSlicer.getHolders();

        uint totalSlices = pieSlicer.totalTokens();
        require(totalSlices > 0, "no nfts sold");

        uint slice = address(this).balance / totalSlices;
        require(slice > 0, "nothing to distribute");
        for (uint i = 0; i < allOwners.length; i++) {
            console.log(slice, pieSlicer.holderBalance(allOwners[i]));

            payable(allOwners[i]).transfer(
                slice * pieSlicer.holderBalance(allOwners[i])
            );
        }

        emit DistributionCompleted(totalSlices, slice);
    }

    function getRewardPerHolder(address holder) public view returns (uint) {
        uint totalSlices = pieSlicer.totalTokens();
        if (totalSlices == 0) return 0;

        uint slice = address(this).balance / totalSlices;
        if (slice == 0) return 0;

        return slice * pieSlicer.holderBalance(holder);
    }

    event TreasuryFunded(uint amount);

    receive() external payable {
        emit TreasuryFunded(msg.value);
    }
}
