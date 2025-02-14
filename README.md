## FundTogether Contracts

## Deployments

- **Contract Address:** [0xD27691901E6366dBD69272754390F170687818F4](https://sepolia.etherscan.io/address/0xD27691901E6366dBD69272754390F170687818F4)
- **Deployment Transaction:** [0x836b551b3613ff86bf9f121072349c69daeb6414a9b237205fe21cf1d686c397](https://sepolia.etherscan.io/tx/0x836b551b3613ff86bf9f121072349c69daeb6414a9b237205fe21cf1d686c397)


## Contracts
CrowdfundingFactory.sol: Factory Contract for creating and managing crowdfunding campaigns
CrowdfundingCampaigns.sol: Crowdfunding Campaign contract for individual crowdfunding campaigns

## Deploying CrowdfundingFactory.sol
```bash
forge script script/deployCrowdfundingFactory.s.sol:DeployCrowdfundingFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```
