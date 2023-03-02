// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/INTNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NTNFT__NftNotTransferrable();
error NTNFT__CanOnlyMintOnce();

contract NTNFT is INTNFT, ERC721 {
    string private constant _TOKEN_URI =
        "https://ipfs.io/ipfs/Qmcx9T9WYxU2wLuk5bptJVwqjtxQPL8SxjgUkoEaDqWzti?filename=BasicNFT.png";
    uint256 private s_tokenCounter;

    mapping(address => bool) private _minter;

    constructor() ERC721("OxAuth", "Ox") {
        s_tokenCounter = 0;
    }

    modifier onlyOnceMint() {
        if (_minter[msg.sender]){
            revert NTNFT__CanOnlyMintOnce();
        }
        _;
    }

    function mintNft() external override onlyOnceMint returns (uint256) {
        _safeMint(msg.sender, s_tokenCounter);
        _minter[msg.sender] = true;
        s_tokenCounter++;
        return s_tokenCounter;
    }

    // // function _beforeTokenTransfer(
    // //     address from,
    // //     address to,
    // //     uint256 /*tokenId*/,
    // //     uint256 /*batchSize*/
    // // ) internal pure override {
    // //     if (from != address(0) || to != address(0)) {
    // //         revert NtNft__NftNotTransferrable();
    // //     }
    // // }

    // function _afterTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     uint256 /*batchSize*/
    // ) internal override {
    //     if (from == address(0)) {
    //         emit Attest(to, tokenId);
    //     } else if (to == address(0)) {
    //         emit Revoke(to, tokenId);
    //     }
    // }

    function burn(uint tokenId) external override {
        if (ownerOf(tokenId) != msg.sender) {
            revert NTNFT__NftNotTransferrable();
        }
        _minter[msg.sender] = false;
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

    /// --- Disabling Transfer Of Soulbound NFT --- ///

    /// @notice Function disabled as cannot transfer a soulbound nft
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function safeTransferFrom(address, address, uint256) public pure override {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function transferFrom(address, address, uint256) public pure override {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function approve(address, uint256) public pure override {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function setApprovalForAll(address, bool) public pure override {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function getApproved(uint256) public pure override returns (address) {
        revert NTNFT__NftNotTransferrable();
    }

    /// @notice Function disabled as cannot transfer a soulbound nft
    function isApprovedForAll(
        address,
        address
    ) public pure override returns (bool) {
        revert NTNFT__NftNotTransferrable();
    }
}