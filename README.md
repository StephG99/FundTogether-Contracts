## FundTogether Contracts

## Deployments

CrowdfundingFactory Contract - [0xbfeb6cbFff39d21A3eD510f5bBAfe3560431766D](https://etherscan.io/address/0xbfeb6cbFff39d21A3eD510f5bBAfe3560431766D)

## Contracts
CrowdfundingFactory.sol: Factory Contract for creating and managing crowdfunding campaigns
CrowdfundingCampaigns.sol: Crowdfunding Campaign contract for individual crowdfunding campaigns

## Deploying CrowdfundingFactory.sol
```bash
forge script script/deployCrowdfundingFactory.s.sol:DeployCrowdfundingFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```
