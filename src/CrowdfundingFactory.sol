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

    Campaign[] public campaigns;
    mapping(address => Campaign[]) public userCampaigns;

    //Emit this event when a campaign is created
    event CampaignCreated(address indexed campaignAddress, address indexed owner, string name, uint256 creationTime);

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

    function createCampaign(string memory _name, uint256 _goal, uint32 _durationInDays) external notPaused {
        CrowdfundingCampaign newCampaign = new CrowdfundingCampaign(msg.sender, _name, _goal, _durationInDays);
        address campaignAddress = address(newCampaign);

        Campaign memory campaign =
            Campaign({campaignAddress: campaignAddress, owner: msg.sender, name: _name, creationTime: block.timestamp});

        campaigns.push(campaign);
        userCampaigns[msg.sender].push(campaign);

        // Emit the new event so the front end can parse the campaign address
        emit CampaignCreated(campaignAddress, msg.sender, _name, block.timestamp);
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
