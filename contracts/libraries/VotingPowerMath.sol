// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
library VotingPowerMath {
    /// @notice Calculates the voting power based on a user's stake.
    /// @dev Implements the Babylonian method for sqrt.
    /// @param stake The raw amount of tokens held by the user.
    /// @return The calculated voting power (sqrt of stake).
    function calculatePower(uint256 stake) internal pure returns (uint256) {
        if (stake == 0) return 0;
        uint256 z = (stake + 1) / 2;
        uint256 y = stake;
        while (z < y) {
            y = z;
            z = (stake / z + z) / 2;
        }
        return y;
    }
}