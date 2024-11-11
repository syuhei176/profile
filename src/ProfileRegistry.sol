// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ProfileNameGroup} from "./ProfileNameGroup.sol";

struct Resource {
    address nftContract;
    uint256 tokenId;
}

struct Profile {
    address nameAddress;
    Resource image;
}

struct ProfileView {
    address nameAddress;
    string name;
    Resource image;
}

contract ProfileRegistry {
    mapping(address => Profile) public profiles;

    mapping(string => address) public nameGroups;

    event ProfileNameGroupCreated(address indexed nameContract, string baseName);
    event ProfileNameUpdated(address indexed user, address nameContract, string name);
    event ProfileImageUpdated(address indexed user, address nftContract, uint256 tokenId);

    function createProfileContract(string memory baseName, uint8 minNameLength) public returns (address) {
        require(nameGroups[baseName] == address(0), "Profile contract already exists");

        address nameContract = address(new ProfileNameGroup(address(this), baseName, minNameLength));

        nameGroups[baseName] = nameContract;

        emit ProfileNameGroupCreated(nameContract, baseName);

        return nameContract;
    }

    function updateProfile(address nameContract, string memory newName, address nftContract, uint256 tokenId) public {
        setProfileName(nameContract, newName);
        setProfileImage(nftContract, tokenId);
    }

    function setProfileName(address nameContract, string memory newName) public {
        address sender = msg.sender;

        Profile storage profile = profiles[sender];

        profile.nameAddress = nameContract;

        ProfileNameGroup(nameContract).updateName(sender, newName);

        emit ProfileNameUpdated(
            sender,
            nameContract,
            newName
        );
    }

    function setProfileImage(address nftContract, uint256 tokenId) public {
        address sender = msg.sender;

        Profile storage profile = profiles[sender];

        profile.image.nftContract = nftContract;
        profile.image.tokenId = tokenId;

        validateProfileImage(sender);

        emit ProfileImageUpdated(
            sender,
            nftContract,
            tokenId
        );
    }

    function getProfile(address user) public view returns (ProfileView memory) {
        Profile storage profile = profiles[user];

        string memory name = ProfileNameGroup(profile.nameAddress).getName(user);

        return ProfileView(
            profile.nameAddress,
            name,
            profile.image
        );
    }

    function validateProfileImage(address user) public view returns (bool) {
        ERC721 imageNFT = ERC721(profiles[user].image.nftContract);

        return imageNFT.ownerOf(profiles[user].image.tokenId) == user;
    }
}