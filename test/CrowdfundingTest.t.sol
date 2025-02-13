// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/CrowdfundingCampaign.sol";
import "../src/CrowdfundingFactory.sol";

contract CrowdfundingTest is Test {
    CrowdfundingFactory factory;
    CrowdfundingCampaign campaign;

    address deployer = address(1);
    address user1 = address(2);
    address user2 = address(3);
    uint256 initialBalance = 10 ether;

    function setUp() public {
        vm.deal(deployer, initialBalance);
        vm.deal(user1, initialBalance);
        vm.deal(user2, initialBalance);

        vm.prank(deployer);
        factory = new CrowdfundingFactory();

        vm.prank(user1);
        factory.createCampaign("Test Campaign", 5 ether, 30);

        // Retrieve the campaign address
        CrowdfundingFactory.Campaign[] memory campaigns = factory
            .getUserCampaigns(user1);
        campaign = CrowdfundingCampaign(payable(campaigns[0].campaignAddress));
    }

    function test_CampaignCreation() public {
        CrowdfundingFactory.Campaign[] memory campaigns = factory
            .getAllCampaigns();
        assertEq(campaigns.length, 1);
        assertEq(campaigns[0].name, "Test Campaign");
    }

    function test_AddTier() public {
        vm.prank(user1);
        campaign.addTier("Basic Support", 1 ether);

        CrowdfundingCampaign.Tier[] memory tiers = campaign.getTiers();
        assertEq(tiers.length, 1);
        assertEq(tiers[0].name, "Basic Support");
        assertEq(tiers[0].amount, 1 ether);
    }

    function test_ContributeToCampaign() public {
        vm.prank(user1);
        campaign.addTier("Basic Support", 1 ether);

        vm.prank(user2);
        campaign.contribute{value: 1 ether}(0);

        assertEq(campaign.getContractBalance(), 1 ether);
        assertEq(campaign.hasContributedTier(user2, 0), true);
    }

    function test_CampaignSuccessAndWithdraw() public {
        vm.prank(user1);
        campaign.addTier("Gold Support", 5 ether);

        vm.prank(user2);
        campaign.contribute{value: 5 ether}(0);

        assertEq(campaign.getContractBalance(), 5 ether);

        // Move time forward past deadline
        vm.warp(block.timestamp + 31 days);

        vm.prank(user1);
        campaign.withdraw();

        assertEq(user1.balance, initialBalance + 5 ether);
        assertEq(campaign.getContractBalance(), 0);
    }

    function test_CampaignFailureAndRefund() public {
        vm.prank(user1);
        campaign.addTier("Silver Support", 3 ether);

        vm.prank(user2);
        campaign.contribute{value: 3 ether}(0);

        assertEq(campaign.getContractBalance(), 3 ether);

        // Move time forward past deadline
        vm.warp(block.timestamp + 31 days);

        vm.prank(user2);
        campaign.refund();

        assertEq(user2.balance, initialBalance);
        assertEq(campaign.getContractBalance(), 0);
    }

    function test_PauseAndUnpauseCampaign() public {
        vm.prank(user1);
        campaign.togglePause();
        assertEq(campaign.paused(), true);

        vm.prank(user1);
        campaign.togglePause();
        assertEq(campaign.paused(), false);
    }

    function test_FactoryPause() public {
        vm.prank(deployer);
        factory.togglePause();
        assertEq(factory.paused(), true);

        vm.expectRevert("Factory is paused");
        vm.prank(user1);
        factory.createCampaign("New Campaign", 3 ether, 20);
    }
}
