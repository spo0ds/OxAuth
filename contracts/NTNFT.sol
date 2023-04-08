// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/INTNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error NTNFT__NftNotTransferrable();
error NTNFT__CanOnlyMintOnce();
error NTNFT__NotNFTOwner();

/// @title OxAuth
/// @author Spooderman
/// @author daleon
/// @notice OxAuth provides the functionality to mint soul bound token but only one address could mint once.

contract NTNFT is INTNFT, ERC721 {
    /// @notice id of the NFT.

    using Counters for Counters.Counter;

    Counters.Counter private s_tokenCounter;

    /// @notice this mapping stores whether that particular address has already minted NFT or not.

    mapping(address => bool) private _minter;

    /*///////////////////////////////////////////////////////////////////////////////
                           Constructor
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice Gives name and symbol to the NFT.

    constructor() ERC721("OxAuth", "Ox") {}

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
        uint256 tokenId = s_tokenCounter.current();
        s_tokenCounter.increment();
        _safeMint(msg.sender, tokenId);
        _minter[msg.sender] = true;
        return tokenId;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           burn
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice allows an owner of the NFT to burn it.
    /// @param tokenId id of an NFT.

    function burn(uint tokenId) external override {
        if (ownerOf(tokenId) != msg.sender) {
            revert NTNFT__NotNFTOwner();
        }
        delete _minter[msg.sender];
        _burn(tokenId);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           View and Pure Functions
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice gets the token URI of an NFT.

    function tokenURI(uint /*tokenId*/) public pure override returns (string memory) {
        return
            "https://ipfs.io/ipfs/Qmcx9T9WYxU2wLuk5bptJVwqjtxQPL8SxjgUkoEaDqWzti?filename=BasicNFT.png";
    }

    /// @notice gets the tokenCounter.
    function getTokenCounter() external view returns (uint) {
        return s_tokenCounter.current();
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
    function safeTransferFrom(address, address, uint256, bytes memory) public pure override {
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
    function isApprovedForAll(address, address) public pure override returns (bool) {
        revert NTNFT__NftNotTransferrable();
    }
}
