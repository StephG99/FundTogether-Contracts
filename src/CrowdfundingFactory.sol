// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CrowdfundingCampaign} from "./CrowdfundingCampaign.sol";

contract CrowdfundingFactory {
    address public owner;
    bool public paused;

    struct Campaign {
        address campaignAddress;
        address owner;
        string name;
        uint256 creationTime;
    }

    event CampaignCreated(address indexed campaignAddress, address indexed owner, string name);

    Campaign[] public campaigns;
    mapping(address => Campaign[]) public userCampaigns;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner.");
        _;
    }

    modifier notPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @param _name The name of the campaign.
     * @param _goal The funding goal in wei.
     * @param _deadlineTimestamp The absolute timestamp for when the campaign ends.
     */
    function createCampaign(string memory _name, uint256 _goal, uint256 _deadlineTimestamp) external notPaused {
        // Pass the timestamp directly to the campaign constructor
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(msg.sender, _name, _goal, _deadlineTimestamp);

        address campaignAddress = address(newCampaign);

        Campaign memory campaign =
            Campaign({campaignAddress: campaignAddress, owner: msg.sender, name: _name, creationTime: block.timestamp});

        campaigns.push(campaign);
        userCampaigns[msg.sender].push(campaign);
        emit CampaignCreated(campaignAddress, msg.sender, _name);
    }

    function getUserCampaigns(address _user) external view returns (Campaign[] memory) {
        return userCampaigns[_user];
    }

    function getAllCampaigns() external view returns (Campaign[] memory) {
        return campaigns;
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }
}
