pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ProfileRegistry, ProfileView} from "../src/ProfileRegistry.sol";
import {ProfileNameGroup} from "../src/ProfileNameGroup.sol";
import {Profile256NFT} from "../src/Profile256NFT.sol";

contract ProfileRegistryTest is Test {
    ProfileRegistry public profileRegistry;
    ProfileNameGroup public profileNameGroup;
    Profile256NFT public profileNFT;
    address public user = address(0x123);

    function setUp() public {
        profileRegistry = new ProfileRegistry();
        profileNameGroup = new ProfileNameGroup(address(profileRegistry), 1, 100);
        profileNFT = new Profile256NFT("Profile256NFT", "PNFT");

        profileRegistry.registerProfileContract("baseName", address(profileNameGroup));
    }

    function testRegisterProfileContract() public {
        ProfileNameGroup newGroup = new ProfileNameGroup(address(profileRegistry), 1, 100);

        profileRegistry.registerProfileContract("newBaseName", address(newGroup));
    }

    function testRegisterProfileContractRevertsIfAlreadyExists() public {
        ProfileNameGroup newGroup = new ProfileNameGroup(address(profileRegistry), 1, 100);

        vm.expectRevert("Profile contract already exists");
        profileRegistry.registerProfileContract("baseName", address(newGroup));
    }

    function testUpdateProfile() public {
        address nameContract = address(profileNameGroup);
        string memory newName = "testName";
        address nftContract = address(profileNFT);
        uint256 tokenId = 1;
        bytes32 metadata = bytes32("testMetadata");
        profileNFT.mintTo(user, tokenId);

        vm.startPrank(user);
        profileRegistry.updateProfile(nameContract, newName, nftContract, tokenId, metadata);
        vm.stopPrank();

        ProfileView memory profile = profileRegistry.getProfile(user);
        assertEq(profile.nameAddress, nameContract);
        assertEq(profile.name, newName);
        assertEq(profile.image.nftContract, nftContract);
        assertEq(profile.image.tokenId, tokenId);
    }

    function testSetProfileName() public {
        address nameContract = address(profileNameGroup);
        string memory newName = "testName";

        vm.startPrank(user);
        profileRegistry.setProfileName(nameContract, newName);
        vm.stopPrank();

        ProfileView memory profile = profileRegistry.getProfile(user);
        assertEq(profile.nameAddress, nameContract);
        assertEq(profile.name, newName);
    }

    function testGetAddressByName() public {
        address nameContract = address(profileNameGroup);
        string memory newName = "testName";

        vm.startPrank(user);
        profileRegistry.setProfileName(nameContract, newName);
        vm.stopPrank();

        address addressByName = profileRegistry.getAddressByName("baseName", newName);
        assertEq(addressByName, user);

        vm.startPrank(user);
        profileRegistry.setProfileName(nameContract, "otherName");
        vm.stopPrank();

        address addressByName2 = profileRegistry.getAddressByName("baseName", "testName");
        assertEq(addressByName2, address(0));
    }

    function testSetProfileImage() public {
        address nameContract = address(profileNameGroup);
        string memory newName = "testName";

        vm.startPrank(user);
        profileRegistry.setProfileName(nameContract, newName);
        vm.stopPrank();

        address nftContract = address(profileNFT);
        uint256 tokenId = 1;

        profileNFT.mintTo(user, tokenId);

        vm.startPrank(user);
        profileRegistry.setProfileImage(nftContract, tokenId);
        vm.stopPrank();

        ProfileView memory profile = profileRegistry.getProfile(user);
        assertEq(profile.image.nftContract, nftContract);
        assertEq(profile.image.tokenId, tokenId);
    }

    function testValidateProfileImage() public {
        address nftContract = address(profileNFT);
        uint256 tokenId = 1;

        profileNFT.mintTo(user, tokenId);

        vm.startPrank(user);
        profileRegistry.setProfileImage(nftContract, tokenId);
        vm.stopPrank();

        bool isValid = profileRegistry.validateProfileImage(user);
        assertTrue(isValid);
    }
}
