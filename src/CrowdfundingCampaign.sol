// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CrowdfundingCampaign {
    string public name;
    uint256 public goal; // Funding goal in wei
    uint256 public deadline;
    address public owner;
    bool public paused;

    enum CampaignState {
        Active,
        Successful,
        Failed
    }

    CampaignState public state;

    struct Tier {
        string name;
        uint256 amount;
        uint256 backers;
    }

    struct Backer {
        uint256 totalContribution;
        mapping(uint256 => bool) contributedTiers;
    }

    Tier[] public tiers;
    mapping(address => Backer) public backers;

    // -----------------
    // EVENTS
    // -----------------
    event TierAdded(string name, uint256 amount);
    event TierRemoved(uint256 index);
    event ContributionReceived(address indexed contributor, uint256 amount, uint256 tierIndex);
    event RefundIssued(address indexed recipient, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);
    event CampaignPaused();
    event CampaignUnpaused();
    event DeadlineExtended(uint256 newDeadline);
    event CampaignStateChanged(CampaignState newState);

    // -----------------
    // MODIFIERS
    // -----------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Not campaign owner");
        _;
    }

    modifier campaignActive() {
        require(state == CampaignState.Active, "Campaign is not Active");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused.");
        _;
    }

    /**
     * @param _owner The address that owns and controls this campaign.
     * @param _name The campaign name (e.g. "My Great Project").
     * @param _goal The funding goal in wei.
     * @param _deadlineTimestamp The unix timestamp (in seconds) at which the campaign ends.
     */
    constructor(address _owner, string memory _name, uint256 _goal, uint256 _deadlineTimestamp) {
        name = _name;
        goal = _goal;
        deadline = _deadlineTimestamp;
        owner = _owner;
        state = CampaignState.Active;
    }

    function checkAndUpdateCampaignState() internal {
        CampaignState oldState = state;
        if (state == CampaignState.Active) {
            if (block.timestamp >= deadline) {
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
            } else {
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Active;
            }
        }

        // If the state has changed, emit an event
        if (oldState != state) {
            emit CampaignStateChanged(state);
        }
    }

    function contribute(uint256 _tierIndex) public payable campaignActive notPaused {
        require(_tierIndex < tiers.length, "Invalid Tier");
        require(msg.value >= tiers[_tierIndex].amount, "Incorrect Amount");

        tiers[_tierIndex].backers++;
        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].contributedTiers[_tierIndex] = true;

        emit ContributionReceived(msg.sender, msg.value, _tierIndex);

        checkAndUpdateCampaignState();
    }

    function addTier(string memory _name, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be > 0");
        tiers.push(Tier(_name, _amount, 0));

        emit TierAdded(_name, _amount);
    }

    function removeTier(uint256 _index) public onlyOwner {
        require(_index < tiers.length, "Tier does not exist");
        require(tiers[_index].backers == 0, "Tier already has backers, cannot remove");

        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();

        emit TierRemoved(_index);
    }

    function withdraw() public onlyOwner {
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successful, "Campaign State not Successful");

        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        payable(owner).transfer(balance);

        emit Withdrawal(owner, balance);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund() public {
        checkAndUpdateCampaignState();
        require(state == CampaignState.Failed, "Refund not available");
        uint256 amount = backers[msg.sender].totalContribution;
        require(amount > 0, "No contribution to refund");

        backers[msg.sender].totalContribution = 0;
        payable(msg.sender).transfer(amount);

        emit RefundIssued(msg.sender, amount);
    }

    /**
     * @dev Returns whether a user contributed to a specific tier index.
     */
    function hasContributedTier(address _backer, uint256 _tierIndex) public view returns (bool) {
        return backers[_backer].contributedTiers[_tierIndex];
    }

    /**
     * @dev Returns the total amount (in wei) a given backer has contributed to this campaign.
     */
    function getContributionOf(address _backer) public view returns (uint256) {
        return backers[_backer].totalContribution;
    }

    function getTiers() public view returns (Tier[] memory) {
        return tiers;
    }

    function togglePause() public onlyOwner {
        paused = !paused;
        if (paused) {
            emit CampaignPaused();
        } else {
            emit CampaignUnpaused();
        }
    }

    function getCampaignStatus() public view returns (CampaignState) {
        if (state == CampaignState.Active && block.timestamp > deadline) {
            return address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
        }
        return state;
    }

    function extendDeadline(uint256 _newDeadlineTimestamp) public onlyOwner campaignActive {
        require(_newDeadlineTimestamp > deadline, "New deadline must be after the current one");

        deadline = _newDeadlineTimestamp;

        emit DeadlineExtended(deadline);
    }
}
