// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IProfileNameGroup} from "./IProfileNameGroup.sol";

contract ProfileNameGroup is IProfileNameGroup {
    mapping(address => string) public addressToName;

    mapping(string => address) public nameToAddress;

    address public profileRegistry;

    uint8 public immutable minNameLength;
    uint8 public immutable maxNameLength;

    error OnlyProfileRegistry();
    error NameTooShort();
    error NameTooLong();
    error NameAlreadyTaken();

    modifier onlyProfileRegistry() {
        if (msg.sender != profileRegistry) {
            revert OnlyProfileRegistry();
        }
        _;
    }

    constructor(address _profileRegistry, uint8 _minNameLength, uint8 _maxNameLength) {
        profileRegistry = _profileRegistry;
        minNameLength = _minNameLength;
        maxNameLength = _maxNameLength;
    }

    function getName(address user) public view returns (string memory) {
        return addressToName[user];
    }

    function getAddress(string memory name) public view returns (address) {
        return nameToAddress[name];
    }

    function updateName(address user, string memory newName) public onlyProfileRegistry {
        delete nameToAddress[addressToName[user]];

        _setName(user, newName);
    }

    function _setName(address user, string memory name) internal {
        if (bytes(name).length <= minNameLength) {
            revert NameTooShort();
        }
        if (bytes(name).length > maxNameLength) {
            revert NameTooLong();
        }
        if (nameToAddress[name] != address(0)) {
            revert NameAlreadyTaken();
        }

        addressToName[user] = name;
        nameToAddress[name] = user;
    }
}
