// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CrowdfundingCampaign {
    address public owner;
    string public name;
    uint goal; //Funding goal in wei
    uint32 startAt;
    uint32 endAt; //Deadline of Campaign
    uint public totalFundsRaised;
    bool public campaignEnded;

    mapping(address => uint) public contributions;

    event ContributionReceived(address indexed contributor, uint amount);
    event CampaignSucceeded(uint totalFundsRaised);
    event CampaignFailed(uint totalFundsRaised);
    event FundsWithdrawn(address indexed owner, uint amount);
    event RefundIssued(address indexed contributor, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not campaign owner");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < endAt, "Campaign has ended");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= endAt, "Campaign still active");
        _;
    }

    constructor(
        string memory _name,
        uint _goal,
        uint32 _startAt,
        uint32 _endAt,
        address _owner
    ) {
        require(_startAt >= block.timestamp, "Invalid Start Date");
        require(_goal > 0, "Invalid goal");
        require(_endAt > block.timestamp, "invalid deadline");

        name = _name;
        goal = _goal;
        endAt = _endAt;
        owner = _owner;
    }

    /**
     * @notice Contribute ETH to the campaign
     */

    function contribute() external payable beforeDeadline {
        require(msg.value > 0, "contribution must be > 0");

        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    function finalizeCampaign() external afterDeadline onlyOwner {
        require(!campaignEnded, "Campaign already ended");

        campaignEnded = true;

        if (totalFundsRaised >= goal) {
            emit CampaignSucceeded(totalFundsRaised);
        } else {
            emit CampaignFailed(totalFundsRaised);
        }
    }

    function refund() external afterDeadline {
        require(campaignEnded, "Campaign not ended");
        require(totalFundsRaised < goal, "Campaign Succeeded");

        uint contribution = contributions[msg.sender];
        require(contribution > 0, "No contribution to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contribution);

        emit RefundIssued(msg.sender, contribution);
    }

    ///////////////////////////////
    /////// GETTER FUNCTIONS //////
    ///////////////////////////////

    function getName() external view returns (string memory) {
        return name;
    }

    function getGoal() external view returns (uint) {
        return goal;
    }

    function getStartAt() external view returns (uint32) {
        return startAt;
    }

    function getEndAt() external view returns (uint32) {
        return endAt;
    }

    function getTotalFundsRaised() external view returns (uint) {
        return totalFundsRaised;
    }

    function hasReachedGoal() external view returns (bool) {
        return totalFundsRaised >= goal;
    }

    function getTimeRemaining() external view returns (uint) {
        if (block.timestamp >= endAt) {
            return 0;
        }
        return endAt - block.timestamp;
    }

    function getContribution(address contributor) external view returns (uint) {
        return contributions[contributor];
    }
}
