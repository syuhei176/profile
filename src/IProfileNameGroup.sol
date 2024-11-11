// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IProfileNameGroup {
    function updateName(address user, string memory newName) external;
    function getName(address user) external view returns (string memory);
}
