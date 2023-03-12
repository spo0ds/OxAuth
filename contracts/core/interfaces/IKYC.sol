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
    function verify(address walletAddress, bytes memory signature) external returns (bool);

    /// @notice generateHash is call the getEthSignedMessageHash and retun the hashed signature of
    function generateHash(address walletAddress) external returns (bytes32);

    /// @notice getEthhashedData is getter function which react the hashData from storage variable who is mapped through address
    function getEthHashedData(address dataProviderAddress) external view returns (bytes32);

    /// @notice GEtUserDAta is function which decrypts the AES encrypted data.
    function decryptMyData(
        address dataProvider,
        string memory data
    ) external view returns (string memory);

    /// @notice UpdateKycDetails is function which updatee the specific KYC data.
    function updateKYCDetails(string memory kycField, string memory data) external;

    /// @notice storeRsaEncryptedinRetrievable is function where data provider encrypts his/her data using requester's public key.
    /// @param dataRequester represents the address of the requester.
    /// @param  kycField This represent the specific field of KYC form such as name, dob and so forth
    /// @param  data represents encrypted data.
    function storeRsaEncryptedinRetrievable(
        address dataRequester,
        string memory kycField,
        string memory data
    ) external;

    /// @notice getRequestedDataFromProvider is function where data requester decrypts data using his/her private key.
    function getRequestedDataFromProvider(
        address dataProvider,
        string memory kycField
    ) external view returns (string memory);
}
