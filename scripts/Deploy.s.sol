// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {GovernanceToken} from "../contracts/token/GovernanceToken.sol";
import {TreasuryTimelock} from "../contracts/treasury/TreasuryTimelock.sol";
import {TreasuryVault} from "../contracts/treasury/TreasuryVault.sol";
import {DAOAccessControl} from "../access/DAOAccessControl.sol";
import {FundPolicy} from "../contracts/funds/FundPolicy.sol";
import {CryptoVenturesGovernor} from "../contracts/governance/CryptoVenturesGovernor.sol";

contract DeployDAO is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        DAOAccessControl access = new DAOAccessControl(deployer);
        GovernanceToken token = new GovernanceToken();
        
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        TreasuryTimelock timelock = new TreasuryTimelock(3600, proposers, executors, deployer);

        TreasuryVault vault = new TreasuryVault(address(access));
        FundPolicy policy = new FundPolicy(address(access));

        CryptoVenturesGovernor governor = new CryptoVenturesGovernor(
            address(access),
            address(token),
            payable(address(timelock)),
            address(policy),
            address(vault)
        );
        access.grantRole(access.PROPOSER_ROLE(), address(governor));
        access.grantRole(access.EXECUTOR_ROLE(), address(timelock));
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        access.grantRole(0x00, address(timelock));
        access.revokeRole(0x00, deployer);
        timelock.revokeRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);

        vm.stopBroadcast();
    }
}