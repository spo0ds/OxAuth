// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../libraries/Types.sol";

interface IKYC {
    function setUserData(
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

    function verify(
        address walletAddress,
        bytes memory signature
    ) external returns (bool);

    function generateHash(address walletAddress) external returns (bytes32);

    // function requestForApproval(
    //     address walletAddress,
    //     address thirdParty,
    //     string memory data
    // ) external;

    // function grantTheRequest(
    //     address approver,
    //     address thirdParty,
    //     string memory data
    // ) external;

    function displayData(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external returns (string memory);

    // function revokeApprove(
    //     address wallletAddress,
    //     address thirdParty,
    //     string memory data
    // ) external;
}
