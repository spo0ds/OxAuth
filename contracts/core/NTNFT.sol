// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/INTNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NtNft__NftNotTransferrable();
error NtNft__NotOwnerToBurn();

contract NtNft is INTNFT, ERC721, Ownable {
    string private constant _TOKEN_URI =
        "https://ipfs.io/ipfs/Qmcx9T9WYxU2wLuk5bptJVwqjtxQPL8SxjgUkoEaDqWzti?filename=BasicNFT.png";
    uint256 private s_tokenCounter;

    constructor() ERC721("OxAuth", "Ox") {
        s_tokenCounter = 0;
    }

    function mintNft(address minter) external override returns (uint256) {
        _safeMint(minter, s_tokenCounter);
        s_tokenCounter++;
        return s_tokenCounter;
    }

    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 /*tokenId*/,
    //     uint256 /*batchSize*/
    // ) internal pure override {
    //     if (from != address(0) || to != address(0)) {
    //         revert NtNft__NftNotTransferrable();
    //     }
    // }

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

    function burn(uint tokenId) external override {
        if (ownerOf(tokenId) != msg.sender) {
            revert NtNft__NotOwnerToBurn();
        }
        _burn(tokenId);
    }

    // function revoke(uint tokenId) external override onlyOwner {
    //     _burn(tokenId);
    // }

    function tokenURI(
        uint /*tokenId*/
    ) public pure override returns (string memory) {
        return _TOKEN_URI;
    }

    function getTokenCounter() external view returns (uint) {
        return s_tokenCounter;
    }
}
