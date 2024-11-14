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
    bytes32 metadata;
}

struct ProfileView {
    address nameAddress;
    string name;
    Resource image;
    bytes32 metadata;
}

contract ProfileRegistry {
    mapping(address => Profile) public profiles;

    mapping(string => address) public nameGroups;

    event ProfileNameGroupCreated(address indexed nameContract, string baseName);
    event ProfileNameUpdated(address indexed user, address nameContract, string name);
    event ProfileImageUpdated(address indexed user, address nftContract, uint256 tokenId);

    function registerProfileContract(string memory baseName, address profileNameGroup) public {
        require(nameGroups[baseName] == address(0), "Profile contract already exists");

        nameGroups[baseName] = profileNameGroup;

        emit ProfileNameGroupCreated(profileNameGroup, baseName);
    }

    function updateProfile(
        address nameContract,
        string memory newName,
        address nftContract,
        uint256 tokenId,
        bytes32 metadata
    ) public {
        setProfileName(nameContract, newName);
        setProfileImage(nftContract, tokenId);
        setProfileMetadata(metadata);
    }

    function setProfileName(address nameContract, string memory newName) public {
        address sender = msg.sender;

        Profile storage profile = profiles[sender];

        profile.nameAddress = nameContract;

        ProfileNameGroup(nameContract).updateName(sender, newName);

        emit ProfileNameUpdated(sender, nameContract, newName);
    }

    function setProfileImage(address nftContract, uint256 tokenId) public {
        address sender = msg.sender;

        Profile storage profile = profiles[sender];

        profile.image.nftContract = nftContract;
        profile.image.tokenId = tokenId;

        validateProfileImage(sender);

        emit ProfileImageUpdated(sender, nftContract, tokenId);
    }

    function setProfileMetadata(bytes32 metadata) public {
        profiles[msg.sender].metadata = metadata;
    }

    function getAddressByName(string memory baseName, string memory name) public view returns (address) {
        return ProfileNameGroup(nameGroups[baseName]).getAddress(name);
    }

    function getProfile(address user) public view returns (ProfileView memory) {
        Profile storage profile = profiles[user];

        string memory name = ProfileNameGroup(profile.nameAddress).getName(user);

        return ProfileView(profile.nameAddress, name, profile.image, profile.metadata);
    }

    function validateProfileImage(address user) public view returns (bool) {
        ERC721 imageNFT = ERC721(profiles[user].image.nftContract);

        return imageNFT.ownerOf(profiles[user].image.tokenId) == user;
    }
}
