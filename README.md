## FundTogether Contracts

## Deployments

- **Contract Address:** [0xA6886D15b04a4025839c39Edd4c8bEe7A6F3E4AD](https://sepolia.etherscan.io/address/0xA6886D15b04a4025839c39Edd4c8bEe7A6F3E4AD)
- **Deployment Transaction:** [0xd1fae2b1bba2037d69bcae2947353ac92fcb5ff0dc10a8fe4876cf9ced89f615](https://sepolia.etherscan.io/tx/0xd1fae2b1bba2037d69bcae2947353ac92fcb5ff0dc10a8fe4876cf9ced89f615)


## Contracts
CrowdfundingFactory.sol: Factory Contract for creating and managing crowdfunding campaigns
CrowdfundingCampaigns.sol: Crowdfunding Campaign contract for individual crowdfunding campaigns

## Deploying CrowdfundingFactory.sol
```bash
forge script script/deployCrowdfundingFactory.s.sol:DeployCrowdfundingFactory --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```
