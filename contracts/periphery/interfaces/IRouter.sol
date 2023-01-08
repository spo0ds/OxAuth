// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IRouter {
    function getNft() external returns (uint);

    function burnNft(uint tokenId) external;

    function revokeNft(uint tokenId) external;

    function fillKycDetails(
        string memory _name,
        string memory _father_name,
        string memory _mother_name,
        string memory _grandFather_name,
        string memory _phone_number,
        string memory _dob,
        string memory _blood_group,
        string memory _citizenship_number,
        string memory _pan_number,
        string memory _location
    ) external;

    function getHash(address walletAddress) external;

    function verifySignature(
        address walletAddress,
        bytes memory signature
    ) external;

    function requestDataFromOtherAddress(
        address walletAddress,
        string memory data,
        uint timePeriod
    ) external;

    function approveOthersRequest(
        address approver,
        address thirdParty,
        string memory data
    ) external;

    function displayApprovedData(
        address walletAddress,
        string memory data
    ) external;

    function removeApprove(address thirdParty, string memory data) external;
}
