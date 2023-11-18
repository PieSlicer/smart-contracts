// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./PieSlicer.sol";

contract SqrTreasury {
    PieSlicer pieSlicer;
    uint public distributionTime;

    constructor() {
        pieSlicer = PieSlicer(msg.sender);
        distributionTime = block.timestamp + 86400;
    }

    // Function to distribute treasury based on square root
    function distributeShares() external {
        address[] memory allHolders = pieSlicer.getHolders();
        uint256 totalHolders = allHolders.length;
        require(totalHolders > 0, "No holders to distribute to");

        // Calculate square root shares for each holder
        uint256[] memory sharesPerHolder = calculateSquareRootShares(
            allHolders
        );

        uint256 totalShares = calculateTotalShares(sharesPerHolder);
        uint totalAmount = address(this).balance;

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
            uint256 amountToDistribute = (shares[i] * totalAmount) /
                totalShares;
            payable(holders[i]).transfer(amountToDistribute);
            emit RewardTransfered(holders[i], amountToDistribute);
        }
    }

    function getRewardPerHolder(address holder) public view returns (uint) {
        address[] memory allHolders = pieSlicer.getHolders();
        uint256 totalHolders = allHolders.length;
        require(totalHolders > 0, "No holders to distribute to");

        // Calculate square root shares for each holder
        uint256[] memory sharesPerHolder = calculateSquareRootShares(
            allHolders
        );

        uint256 totalShares = calculateTotalShares(sharesPerHolder);
        uint totalAmount = address(this).balance;

        for (uint256 i = 0; i < sharesPerHolder.length; i++) {
            if (allHolders[i] == holder)
                return (sharesPerHolder[i] * totalAmount) / totalShares;
        }
        return 0;
    }

    event TreasuryFunded(uint amount);

    receive() external payable {
        emit TreasuryFunded(msg.value);
    }
}
