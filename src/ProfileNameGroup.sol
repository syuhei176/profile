// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IProfileNameGroup} from "./IProfileNameGroup.sol";

contract ProfileNameGroup is IProfileNameGroup {
    mapping(address => string) public addressToName;

    mapping(string => address) public nameToAddress;

    address public profileRegistry;

    string public baseName;
    uint8 immutable public minNameLength;

    modifier onlyProfileRegistry() {
        require(msg.sender == profileRegistry, "Only the profile registry can call this function");
        _;
    }

    constructor(
        address _profileRegistry,
        string memory _baseName,
        uint8 _minNameLength
    ) {
        profileRegistry = _profileRegistry;
        baseName = _baseName;
        minNameLength = _minNameLength;
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
        require(bytes(name).length > minNameLength, "Name too short");

        require(nameToAddress[name] == address(0), "Name already taken");

        addressToName[user] = name;
        nameToAddress[name] = user;
    }
}
