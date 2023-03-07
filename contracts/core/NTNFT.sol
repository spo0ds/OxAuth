// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/INTNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error NTNFT__NftNotTransferrable();
error NTNFT__CanOnlyMintOnce();

/// @title OxAuth
/// @author Spooderman
/// @author daleon
/// @notice OxAuth provides the functionality to mint soul bound token but only one address could mint once.

contract NTNFT is INTNFT, ERC721 {
    /// @notice this constant variable stores the link of the IPFS on which the actual image of the NFT lies.
    string private constant _TOKEN_URI =
        "https://ipfs.io/ipfs/Qmcx9T9WYxU2wLuk5bptJVwqjtxQPL8SxjgUkoEaDqWzti?filename=BasicNFT.png";

    /// @notice id of the NFT.

    uint256 private s_tokenCounter;

    /// @notice this mapping stores whether that particular address has already minted NFT or not.

    mapping(address => bool) private _minter;

    /*///////////////////////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice Gives name and symbol to the NFT.

    constructor() ERC721("OxAuth", "Ox") {
        // s_tokenCounter = 0;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           Modifier
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice passes if an address has not minted NFT before else reverts.

    modifier onlyOnceMint() {
        if (_minter[msg.sender]) {
            revert NTNFT__CanOnlyMintOnce();
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           mintNft
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice allows an address to mint an NFT.

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

    /*///////////////////////////////////////////////////////////////////////////////
                           burn
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice allows an owner of the NFT to burn it.
    /// @param tokenId id of an NFT.

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

    /*///////////////////////////////////////////////////////////////////////////////
                           View and Pure Functions
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice gets the token URI of an NFT.

    function tokenURI(
        uint /*tokenId*/
    ) public pure override returns (string memory) {
        return _TOKEN_URI;
    }

    /// @notice gets the tokenCounter.
    function getTokenCounter() external view returns (uint) {
        return s_tokenCounter;
    }

    /// @notice returns whether an address has minted NFT or not
    function hasMinted(address minter) external view returns (bool) {
        return _minter[minter];
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           Transfers and Approve Functions
    ///////////////////////////////////////////////////////////////////////////////*/

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
