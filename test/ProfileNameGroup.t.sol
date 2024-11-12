// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ProfileNameGroup} from "../src/ProfileNameGroup.sol";
import {ProfileRegistry} from "../src/ProfileRegistry.sol";

contract ProfileNameGroupTest is Test {
    ProfileNameGroup public profileNameGroup;
    ProfileRegistry public profileRegistry;
    address public user = address(0x123);
    address public user2 = address(0x456);

    function setUp() public {
        profileRegistry = new ProfileRegistry();
        profileNameGroup = new ProfileNameGroup(address(profileRegistry), 1, 20);
    }

    function testGetName() public {
        vm.startPrank(address(profileRegistry));

        string memory name = "testName";
        profileNameGroup.updateName(user, name);

        vm.stopPrank();

        assertEq(profileNameGroup.getName(user), name);
    }

    function testGetAddress() public {
        vm.startPrank(address(profileRegistry));

        string memory name = "testName";
        profileNameGroup.updateName(user, name);

        vm.stopPrank();

        assertEq(profileNameGroup.getAddress(name), user);
    }

    function testUpdateName() public {
        vm.startPrank(address(profileRegistry));

        string memory name = "testName";
        profileNameGroup.updateName(user, name);
        assertEq(profileNameGroup.getName(user), name);
        assertEq(profileNameGroup.getAddress(name), user);

        string memory newName = "testNewName";
        profileNameGroup.updateName(user, newName);
        assertEq(profileNameGroup.getName(user), newName);
        assertEq(profileNameGroup.getAddress(newName), user);
        assertEq(profileNameGroup.getAddress(name), address(0));

        vm.stopPrank();
    }

    function testSetNameRevertsIfEmpty() public {
        vm.startPrank(address(profileRegistry));

        vm.expectRevert(ProfileNameGroup.NameTooShort.selector);
        profileNameGroup.updateName(user, "");

        vm.stopPrank();
    }

    function testSetNameRevertsIfNameAlreadyTaken() public {
        vm.startPrank(address(profileRegistry));

        profileNameGroup.updateName(user, "testName");

        vm.expectRevert(ProfileNameGroup.NameAlreadyTaken.selector);
        profileNameGroup.updateName(user2, "testName");

        vm.stopPrank();
    }

    function testSetNameSuccessIfNameNotTaken() public {
        vm.startPrank(address(profileRegistry));

        profileNameGroup.updateName(user, "testName");
        profileNameGroup.updateName(user, "testName2");

        profileNameGroup.updateName(user2, "testName");

        vm.expectRevert(ProfileNameGroup.NameAlreadyTaken.selector);
        profileNameGroup.updateName(user2, "testName2");

        vm.stopPrank();
    }
}
