// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/CrowdfundingCampaign.sol";

contract ReentrancyAttackTest is Test {
    CrowdfundingCampaign campaign;
    ReentrancyAttacker attacker;

    address deployer = address(1);
    address user1 = address(2);
    uint256 initialBalance = 10 ether;

    function setUp() public {
        vm.deal(deployer, initialBalance);
        vm.deal(user1, initialBalance);

        vm.prank(user1);
        campaign = new CrowdfundingCampaign(
            user1,
            "Reentrancy Test",
            5 ether,
            30
        );

        vm.prank(user1);
        campaign.addTier("Exploit Tier", 1 ether);
    }

    function test_ReentrancyAttackFails() public {
        // Deploy attacker contract
        attacker = new ReentrancyAttacker(address(campaign));
        vm.deal(address(attacker), 2 ether);

        // Attacker contributes 1 ether
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}(0);

        // Move forward in time to simulate campaign success
        vm.warp(block.timestamp + 31 days);

        // Expect revert due to security against reentrancy
        vm.expectRevert();
        vm.prank(user1);
        campaign.withdraw();
    }
}

// Malicious Reentrancy Contract
contract ReentrancyAttacker {
    CrowdfundingCampaign public target;
    bool public attackInitiated;

    constructor(address _campaign) {
        target = CrowdfundingCampaign(_campaign);
    }

    function attack(uint256 _tierIndex) external payable {
        // Contribute first to be eligible for withdraw
        target.contribute{value: msg.value}(_tierIndex);
        attackInitiated = true;
    }

    receive() external payable {
        if (attackInitiated) {
            attackInitiated = false; // Prevent infinite loop
            target.withdraw(); // Try re-entering the function
        }
    }
}