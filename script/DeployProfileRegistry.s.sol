// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "forge-std/console2.sol";
import {ProfileRegistry} from "../src/ProfileRegistry.sol";
import {ProfileNameGroup} from "../src/ProfileNameGroup.sol";

contract DeployProfileRegistry is Script {
    function setUp() public {}

    function run() public returns (ProfileRegistry profileRegistry) {
        vm.startBroadcast();

        profileRegistry =
            new ProfileRegistry{salt: 0x0000000000000000000000000000000000000000000000000000000000000777}();

        ProfileNameGroup profileNameGroup = new ProfileNameGroup{
            salt: 0x0000000000000000000000000000000000000000000000000000000000000777
        }(address(profileRegistry), 1, 96);

        profileRegistry.registerProfileContract("default", address(profileNameGroup));

        vm.stopBroadcast();

        console2.log("ProfileRegistry Deployed:", address(profileRegistry));
        console2.log("ProfileNameGroup Deployed:", address(profileNameGroup));
    }
}
