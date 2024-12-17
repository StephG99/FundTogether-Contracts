// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./CrowdfundingCampaign.sol";

contract CrowdfundingFactory {
    // Array to store deployed campaigns
    CrowdfundingCampaign[] public campaigns;

    // Mapping to validate campaigns
    mapping(address => bool) public isCampaign;

    // Event emitted when a new campaign is created
    event CampaignCreated(
        address indexed campaignAddress,
        string name,
        uint256 goal,
        uint256 deadline,
        address owner
    );

    /**
     * @notice Create a new crowdfunding campaign
     * @param _name The name of the campaign
     * @param _goal The funding goal in wei
     * @param _deadline Duration of the campaign in seconds
     * @param _rewardToken Address of the reward token contract
     */
    function createCampaign(
        string memory _name,
        uint256 _goal,
        uint256 _deadline,
        address _rewardToken
    ) external {
        // Deploy a new CrowdfundingCampaign contract
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(
            _name,
            _goal,
            block.timestamp + _deadline,
            _rewardToken,
            msg.sender
        );

        // Store the campaign in the array and mark it as valid
        campaigns.push(newCampaign);
        isCampaign[address(newCampaign)] = true;

        emit CampaignCreated(address(newCampaign), _name, _goal, _deadline, msg.sender);
    }

    /**
     * @notice Get the total number of campaigns
     */
    function getTotalCampaigns() external view returns (uint256) {
        return campaigns.length;
    }
}
