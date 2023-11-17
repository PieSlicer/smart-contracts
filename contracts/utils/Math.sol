// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Math {
    // Babylonian method for square root calculation
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        return y;
    }
}

