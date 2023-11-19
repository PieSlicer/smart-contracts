// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./PieSlicer.sol";

/**
 * @title SqrTreasury Smart Contract
 * @dev Manages the distribution of funds from a treasury to Pie Slicer holders using a square root algorithm.
 */
contract SqrTreasury {
    PieSlicer pieSlicer;
    uint public distributionTime;

    /**
     * @dev Constructor function initializing the Pie Slicer connection and setting the distribution time.
     */
    constructor() {
        pieSlicer = PieSlicer(msg.sender);
        distributionTime = block.timestamp + 86400;
    }

    /**
     * @dev External function to distribute treasury funds to Pie Slicer holders based on a square root algorithm. Called by PowerPool
     */
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

    /**
     * @dev Internal function to calculate square root shares for each holder.
     * @param allHolders Array of all Pie Slicer holders.
     * @return sharesPerHolder Array containing the calculated square root shares for each holder.
     */
    function calculateSquareRootShares(
        address[] memory allHolders
    ) internal view returns (uint256[] memory) {
        uint256[] memory sharesPerHolder = new uint256[](allHolders.length);

        for (uint256 i = 0; i < allHolders.length; i++) {
            sharesPerHolder[i] = sqrt(pieSlicer.holderBalance(allHolders[i]));
        }

        return sharesPerHolder;
    }

    /**
     * @dev Internal function implementing the Babylonian method for calculating square root.
     * @param x Input value for square root calculation.
     * @return Square root of the input value.
     */
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

    /**
     * @dev Internal function to calculate the total shares.
     * @param shares Array containing the calculated square root shares for each holder.
     * @return totalShares Total sum of all square root shares.
     */
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

    /**
     * @dev Internal function to distribute funds to holders based on their square root shares.
     * @param holders Array of all Pie Slicer holders.
     * @param shares Array containing the calculated square root shares for each holder.
     * @param totalAmount Total amount of funds in the treasury.
     * @param totalShares Total sum of all square root shares.
     */ function distributeFunds(
        address[] memory holders,
        uint256[] memory shares,
        uint256 totalAmount,
        uint totalShares
    ) internal {
        for (uint256 i = 0; i < shares.length; i++) {
            // Distribute funds to each holder based on their share
            uint256 amountToDistribute = (shares[i] * totalAmount) /
                totalShares;
            if (amountToDistribute > 0) {
                payable(holders[i]).transfer(amountToDistribute);
                emit RewardTransfered(holders[i], amountToDistribute);
            }
        }
    }

    /**
     * @dev External function to retrieve the reward amount for a specific holder.
     * @param holder Address of the holder.
     * @return rewardPerHolder Amount of reward for the specified holder.
     */
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
