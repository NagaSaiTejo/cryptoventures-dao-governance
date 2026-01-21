// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IFundPolicy} from "../interfaces/IFundPolicy.sol";
import {DAOAccessControl} from "../access/DAOAccessControl.sol";
contract FundPolicy is IFundPolicy {
    DAOAccessControl public immutable accessControl;
    Tier[] private _tiers;
    event TierAdded(uint256 minQuorum, uint256 votingPeriod, uint256 maxAmount, uint256 executionDelay);
    constructor(address _accessControl) {
        accessControl = DAOAccessControl(_accessControl);
        _addTier(400, 21600, 10 ether, 3600);
        _addTier(1000, 50400, 100 ether, 86400);
        _addTier(2000, 100800, type(uint256).max, 259200);
    }
    function getTierForAmount(uint256 amount) external view override returns (Tier memory) {
        for (uint256 i = 0; i < _tiers.length; i++) {
            if (amount <= _tiers[i].maxAmount) return _tiers[i];
        }
        return _tiers[_tiers.length - 1];
    }
    function addTier(uint256 minQuorum, uint256 votingPeriod, uint256 maxAmount, uint256 executionDelay) external {
        require(accessControl.hasRole(accessControl.DEFAULT_ADMIN_ROLE(), msg.sender), "FundPolicy: Restricted to Admin");
        _addTier(minQuorum, votingPeriod, maxAmount, executionDelay);
    }
    function _addTier(uint256 minQuorum, uint256 votingPeriod, uint256 maxAmount, uint256 executionDelay) internal {
        _tiers.push(Tier(minQuorum, votingPeriod, maxAmount, executionDelay));
        emit TierAdded(minQuorum, votingPeriod, maxAmount, executionDelay);
    }
    function getTotalTiers() external view returns (uint256) {
        return _tiers.length;
    }
}