// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IFundPolicy {
    struct Tier {
        uint256 minQuorum;
        uint256 votingPeriod;
        uint256 maxAmount;
        uint256 executionDelay;
    }
    function getTierForAmount(uint256 amount) external view returns (Tier memory);
}