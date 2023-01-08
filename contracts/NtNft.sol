// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NtNft__NftNotTransferrable();
error NtNft__NotOwnerToBurn();

contract NtNft is ERC721, Ownable {
    string public constant TOKEN_URI =
        "https://ipfs.io/ipfs/Qmcx9T9WYxU2wLuk5bptJVwqjtxQPL8SxjgUkoEaDqWzti?filename=BasicNFT.png";
    uint256 private s_tokenCounter;

    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    constructor() ERC721("OxAuth", "Ox") {
        s_tokenCounter = 0;
    }

    function mintNft() public returns (uint256) {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        return s_tokenCounter;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /*tokenId*/,
        uint256 /*batchSize*/
    ) internal override {
        if (from != address(0) || to != address(0)) {
            revert NtNft__NftNotTransferrable();
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 /*batchSize*/
    ) internal override {
        if (from == address(0)) {
            emit Attest(to, tokenId);
        } else if (to == address(0)) {
            emit Revoke(to, tokenId);
        }
    }

    function burn(uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) {
            revert NtNft__NotOwnerToBurn();
        }
        _burn(tokenId);
    }

    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function tokenURI(
        uint256 /*tokenId*/
    ) public pure override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
