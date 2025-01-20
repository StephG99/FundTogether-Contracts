// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "../src/CrowdfundingFactory.sol";

contract DeployCrowdfundingFactory is Script {
    function setUp() public {}

    function run() external {
        // Load private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(deployerPrivateKey);
        console.log("Account", account);
        // Start broadcasting transactions (required for deployment)

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the CrowdfundingFactory contract
        CrowdfundingFactory factory = new CrowdfundingFactory();

        // Log the address of the deployed contract
        console.log("CrowdfundingFactory deployed at:", address(factory));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
