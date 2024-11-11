// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Profile256NFT} from "../src/Profile256NFT.sol";

contract ProfileNFTTest is Test {
    Profile256NFT public profileNFT;

    function setUp() public {
        profileNFT = new Profile256NFT("Profile256NFT", "PNFT");
    }

    function testMintTo() public {
        address recipient = address(0x123);
        uint256 tokenId = 1;
        profileNFT.mintTo{value: 0.1 ether}(recipient, tokenId);
        assertEq(profileNFT.ownerOf(tokenId), recipient);
    }

    function testBurn() public {
        address recipient = address(this);
        uint256 tokenId = 1;

        profileNFT.mintTo(recipient, tokenId);

        profileNFT.burn(tokenId);
    }

    function testTokenURI() public {
        address recipient = address(this);
        uint256 tokenId = 25000013;
        profileNFT.mintTo(recipient, tokenId);
        string memory uri = profileNFT.tokenURI(tokenId);
        assertGt(bytes(uri).length, 0);
    }
}
