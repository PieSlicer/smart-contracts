// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./PieSlicer.sol";
import "hardhat/console.sol";

contract QuadraticTreasuryDistribution {
    PieSlicer pieSlicer;

    constructor() {
        pieSlicer = PieSlicer(msg.sender);
    }

    // Function to distribute treasury based on square root
    function distributeShares() external {
        address[] memory allHolders = pieSlicer.getHolders();

        uint256 totalHolders = allHolders.length;
        console.log("totalHolders", totalHolders);

        require(totalHolders > 0, "No holders to distribute to");

        uint totalNFTs = pieSlicer.totalTokens();

        console.log("totalNFTs", totalNFTs);

        // Calculate square root shares for each holder
        uint256[] memory sharesPerHolder = calculateSquareRootShares(
            allHolders
        );

        console.log("sharesPerHolder[0]", sharesPerHolder[0]);

        // Normalize shares to ensure the total matches the total amount
        uint256 totalShares = calculateTotalShares(sharesPerHolder);
        console.log("totalShares", totalShares);

        // uint256[] memory normalizedShares = normalizeShares(
        //     sharesPerHolder,
        //     totalNFTs,
        //     totalShares
        // );

        // console.log("normalizedShares[0]", normalizedShares[0]);
        // console.log("normalizedShares[1]", normalizedShares[1]);
        // console.log("normalizedShares[2]", normalizedShares[2]);

        uint totalAmount = address(this).balance;

        console.log("totalAmount", totalAmount);

        // Distribute funds to holders
        distributeFunds(allHolders, sharesPerHolder, totalAmount, totalShares);
    }

    // Function to calculate square root shares for each holder
    function calculateSquareRootShares(
        address[] memory allHolders
    ) internal view returns (uint256[] memory) {
        uint256[] memory sharesPerHolder = new uint256[](allHolders.length);

        for (uint256 i = 0; i < allHolders.length; i++) {
            sharesPerHolder[i] = sqrt(pieSlicer.holderBalance(allHolders[i]));
            console.log(
                "sqrt",
                sharesPerHolder[i],
                "balance",
                pieSlicer.holderBalance(allHolders[i])
            );
        }

        return sharesPerHolder;
    }

    // Babylonian method for calculating square root
    // Function to calculate the square root with rounding to the nearest integer
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        // Check if z^2 is greater than x, if yes, subtract 1
        if ((z * z) > x) {
            z -= 1;
        }

        return z;
    }

    // Function to calculate the total shares
    function calculateTotalShares(
        uint256[] memory shares
    ) internal pure returns (uint256) {
        uint256 totalShares = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            totalShares += shares[i];
        }
        return totalShares;
    }

    // Function to normalize shares to ensure the total matches the total NFTs
    // function normalizeShares(
    //     uint256[] memory shares,
    //     uint256 totalNFTs,
    //     uint256 totalShares
    // ) internal pure returns (uint256[] memory) {
    //     uint256[] memory normalizedShares = new uint256[](shares.length);
    //     for (uint256 i = 0; i < shares.length; i++) {
    //         normalizedShares[i] = (shares[i] * totalNFTs) / totalShares;
    //     }
    //     return normalizedShares;
    // }

    event RewardTransfered(address to, uint amount);

    // Function to distribute funds to holders
    function distributeFunds(
        address[] memory holders,
        uint256[] memory shares,
        uint256 totalAmount,
        uint totalShares
    ) internal {
        for (uint256 i = 0; i < shares.length; i++) {
            // Distribute funds to each holder based on their share
            uint256 amountToDistribute = (shares[i] * totalAmount) / totalShares;
            payable(holders[i]).transfer(amountToDistribute);
            console.log("Distribution for", i, "shares[i]: ", shares[i]);
            console.log(
                "Distribution for",
                i,
                "amount to distribute: ",
                amountToDistribute
            );

            emit RewardTransfered(holders[i], amountToDistribute);
        }
    }

    event TreasuryFunded(uint amount);

    receive() external payable {
        emit TreasuryFunded(msg.value);
    }
}
