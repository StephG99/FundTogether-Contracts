## FundTogether Contracts

## Deployments

- **Contract Address:** [0x13901a037e070be7ff6d0454ef38c131ac1f4215](https://sepolia.etherscan.io/address/0x13901a037e070be7ff6d0454ef38c131ac1f4215)
- **Deployment Transaction:** [0x348ae7d2845046a462e70632b453fc7cd412b5d197b931e251d1090d167b78ea](https://sepolia.etherscan.io/tx/0x348ae7d2845046a462e70632b453fc7cd412b5d197b931e251d1090d167b78ea)


## Contracts
CrowdfundingFactory.sol: Factory Contract for creating and managing crowdfunding campaigns
CrowdfundingCampaigns.sol: Crowdfunding Campaign contract for individual crowdfunding campaigns

## Deploying CrowdfundingFactory.sol
```bash
forge script script/deployCrowdfundingFactory.s.sol:DeployCrowdfundingFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```
