// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {VotingPowerMath} from "../libraries/VotingPowerMath.sol";

/**
 * @title GovernanceToken
 * @dev Implements ERC20 with snapshots (votes) and square-root weighted voting power.
 */
contract GovernanceToken is ERC20, ERC20Permit, ERC20Votes {
    constructor()
        ERC20("CryptoVentures Token", "CVT")
        ERC20Permit("CryptoVentures Token")
    {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @notice Returns the weighted voting power for an account at a specific block.
     */
    function getWeightedVotingPower(
        address account,
        uint256 timepoint
    ) public view returns (uint256) {
        uint256 rawStake = getPastVotes(account, timepoint);
        return VotingPowerMath.calculatePower(rawStake);
    }

    /**
     * @notice Returns the weighted total supply at a block for quorum calculations.
     * @dev Applies SQRT logic to the total supply to remain consistent with individual weights.
     */
    function getPastTotalWeightedSupply(uint256 timepoint) public view returns (uint256) {
        uint256 rawTotalSupply = getPastTotalSupply(timepoint);
        return VotingPowerMath.calculatePower(rawTotalSupply);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    )
        public
        view
        override(
            ERC20Permit,
            Nonces 
        )
        returns (uint256)
    {
        return super.nonces(owner);
    }
}