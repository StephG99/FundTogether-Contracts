// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./CrowdfundingCampaign.sol";

contract CrowdfundingFactory {
    // Array to store deployed campaigns
    CrowdfundingCampaign[] public campaigns;

    // Mapping to validate campaign addresses
    mapping(address => bool) public isCampaign;

    // Event emitted when a new campaign is created
    event CampaignCreated(
        address indexed campaignAddress, string name, uint256 goal, uint32 startAt, uint32 endAt, address owner
    );

    /**
     * @notice Create a new crowdfunding campaign
     * @param _name The name of the campaign
     * @param _goal The funding goal in wei
     * @param _startAt The start time of the campaign
     * @param _endAt The end time (deadline) of the campaign
     */
    function createCampaign(string memory _name, uint256 _goal, uint32 _startAt, uint32 _endAt) external {
        // Validate input
        require(_startAt >= block.timestamp, "Invalid start time");
        require(_endAt > _startAt, "Invalid end time");

        // Deploy the campaign
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(_name, _goal, _startAt, _endAt, msg.sender);

        // Add the campaign to the array and mapping
        campaigns.push(newCampaign);
        isCampaign[address(newCampaign)] = true;

        // Emit the campaign creation event
        emit CampaignCreated(address(newCampaign), _name, _goal, _startAt, _endAt, msg.sender);
    }

    /**
     * @notice Get the total number of campaigns
     */
    function getTotalCampaigns() external view returns (uint256) {
        return campaigns.length;
    }

    /**
     * @notice Validate if an address is a campaign
     * @param campaignAddress The address of the campaign to validate
     * @return True if the address is a valid campaign, false otherwise
     */
    function validateCampaign(address campaignAddress) external view returns (bool) {
        return isCampaign[campaignAddress];
    }

    function getCampaignAddress(uint256 index) external view returns (address) {
        require(index < campaigns.length, "Invalid index");
        return address(campaigns[index]);
    }
}
