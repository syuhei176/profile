// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


import {ERC721} from "solmate/tokens/ERC721.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";

contract Profile256NFT is ERC721 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function mintTo(address recipient, uint256 tokenId) public returns (uint256) {
        _mint(recipient, tokenId);

        return tokenId;
    }

    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");

        _burn(tokenId);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        string memory name = Strings.toString(id);
        string memory description = string(abi.encodePacked("256 bits image of ", name));
        string memory image = Base64.encode(generatePixelArt(bytes32(id)));

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                'data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

   function generatePixelArt(bytes32 data) public pure returns (bytes memory) {
        string memory svgStart = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' width='320' height='320'>";
        string memory svgEnd = "</svg>";
        string memory svgContent;

        // 各ピクセルのサイズと位置を決め、色を設定
        for (uint8 i = 0; i < 16; i++) {
            for (uint8 j = 0; j < 16; j++) {
                // dataの各バイトから色を生成
                uint8 colorValue = getBit(data, i * 16 + j);
                string memory color = colorValue == 1 ? "rgb(255,255,255)" : "rgb(5,5,5)";

                // ピクセルの四角形をSVGで定義
                svgContent = string(abi.encodePacked(
                    svgContent,
                    "<rect width='1' height='1' x='", uint2str(j), "' y='", uint2str(i),
                    "' fill='", color, "'/>"
                ));
            }
        }

        // SVG全体を組み立て
        return (abi.encodePacked(svgStart, svgContent, svgEnd));
    }

    function getBit(bytes32 data, uint8 index) public pure returns (uint8) {
        require(index < 256, "Index out of range");
        uint8 byteIndex = index / 8;
        uint8 bitIndex = index % 8;
        return uint8((data[byteIndex] >> (7 - bitIndex)) & 0x01);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
