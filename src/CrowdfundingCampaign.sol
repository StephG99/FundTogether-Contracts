// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./TokenReward.sol";

contract CrowdfundingCampaign {
    string public name;
    address public owner;
    uint256 public goal; // Funding goal
    uint256 public deadline; // Campaign deadline
    uint256 public totalFundsRaised;

    TokenReward public rewardToken;
    bool public campaignEnded;

    mapping(address => uint256) public contributions;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event CampaignSucceeded(uint256 totalFundsRaised);
    event CampaignFailed(uint256 totalFundsRaised);
    event TokensClaimed(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not campaign owner");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Campaign has ended");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Campaign still active");
        _;
    }

    constructor(
        string memory _name,
        uint256 _goal,
        uint256 _deadline,
        address _rewardToken,
        address _owner
    ) {
        require(_goal > 0, "Invalid goal");
        require(_deadline > block.timestamp, "Invalid deadline");

        name = _name;
        goal = _goal;
        deadline = _deadline;
        rewardToken = TokenReward(_rewardToken);
        owner = _owner;
    }

    /**
     * @notice Contribute ETH to the campaign
     */
    function contribute() external payable beforeDeadline {
        require(msg.value > 0, "Contribution must be > 0");

        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    /**
     * @notice End the campaign manually after the deadline
     */
    function finalizeCampaign() external afterDeadline onlyOwner {
        require(!campaignEnded, "Campaign already ended");

        campaignEnded = true;

        if (totalFundsRaised >= goal) {
            emit CampaignSucceeded(totalFundsRaised);
            rewardToken.transferFrom(owner, address(this), totalFundsRaised);
        } else {
            emit CampaignFailed(totalFundsRaised);
        }
    }

    /**
     * @notice Claim reward tokens proportional to contribution
     */
    function claimTokens() external afterDeadline {
        require(campaignEnded, "Campaign not ended");
        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions");

        uint256 rewardAmount = (contribution * rewardToken.balanceOf(address(this))) / totalFundsRaised;
        contributions[msg.sender] = 0;

        rewardToken.transfer(msg.sender, rewardAmount);

        emit TokensClaimed(msg.sender, rewardAmount);
    }

    /**
     * @notice Withdraw ETH raised if the campaign is successful
     */
    function withdrawFunds() external onlyOwner afterDeadline {
        require(campaignEnded, "Campaign not ended");
        require(totalFundsRaised >= goal, "Goal not met");

        payable(owner).transfer(totalFundsRaised);
    }

    /**
     * @notice Refund contributors if the campaign failed
     */
    function refund() external afterDeadline {
        require(campaignEnded, "Campaign not ended");
        require(totalFundsRaised < goal, "Campaign succeeded");

        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contribution);
    }
}
