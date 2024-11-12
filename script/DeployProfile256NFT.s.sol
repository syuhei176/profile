// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "forge-std/console2.sol";
import {Profile256NFT} from "../src/Profile256NFT.sol";

contract DeployProfile256NFT is Script {
    function setUp() public {}

    function run() public returns (Profile256NFT profile256NFT) {
        vm.startBroadcast();

        profile256NFT = new Profile256NFT{salt: 0x0000000000000000000000000000000000000000000000000000000000000777}(
            "Profile256NFT", "P256"
        );

        vm.stopBroadcast();

        console2.log("Profile256NFT Deployed:", address(profile256NFT));
    }
}
