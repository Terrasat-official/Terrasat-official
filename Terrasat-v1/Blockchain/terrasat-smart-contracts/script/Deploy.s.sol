// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CarbonCreditToken.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();
        new CarbonCreditToken();
        vm.stopBroadcast();
    }
}
