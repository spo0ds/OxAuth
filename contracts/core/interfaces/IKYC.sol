// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../libraries/Types.sol";

interface IKYC {
    /// @notice SetUserData is used to set User data and mapped to it address
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

    /// @notice Verify whether the Kyc details is signed by the right DataProviderAddress
    function verify(
        address walletAddress,
        bytes memory signature
    ) external returns (bool);

    /// @notice generateHash is call the getEthSignedMessageHash and retun the hashed signature of
    function generateHash(address walletAddress) external returns (bytes32);

    /// @notice GEtUserDAta is function which provide the specific KYC datg to user who request to See Details.
    function getUserData(
        address dataProvider,
        string memory data
    ) external returns (string memory);
}
