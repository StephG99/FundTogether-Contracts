## FundTogether Contracts

## Deployments

CrowdfundingFactory Contract - [0xe8faa3ce9ba1b8433f5f54f500f5d0d015bb82a0](https://sepolia.etherscan.io/tx/0xf14fefd743679644d5491995d05c45c5f56ec70f8ca9806901fa2fb681efd4e0)

## Contracts
CrowdfundingFactory.sol: Factory Contract for creating and managing crowdfunding campaigns
CrowdfundingCampaigns.sol: Crowdfunding Campaign contract for individual crowdfunding campaigns

## Deploying CrowdfundingFactory.sol
```bash
forge script script/deployCrowdfundingFactory.s.sol:DeployCrowdfundingFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```
