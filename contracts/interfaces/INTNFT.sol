// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface INTNFT {
    /// @notice allows an address to mint an NFT.
    function mintNft() external returns (uint256);

    /// @notice allows an owner of the NFT to burn it.
    function burn(uint tokenId) external;

    // function revoke(uint tokenId) external;

    /// @notice gets the tokenCounter.
    function getTokenCounter() external view returns (uint);

    function hasMinted(address minter) external view returns (bool);
}
