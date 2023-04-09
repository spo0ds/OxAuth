// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IKYC} from "./interfaces/IKYC.sol";
import {Types} from "./libraries/Types.sol";
import {IOxAuth} from "./interfaces/IOxAuth.sol";
import {OxAuth} from "./OxAuth.sol";
import {INTNFT} from "./interfaces/INTNFT.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error KYC__INVALIDSignatureLength();
error KYC__CannotViewData();
error KYC__DataDoesNotExist();
error KYC__FieldDoesNotExist();
error KYC__AddressHasNotMinted();
error KYC__NotYetApprovedToEncryptWithPublicKey();
error KYC__NotOwner();
error KYC__NotYetApprovedToView();

/// @title KYC Interaction
/// @author Spooderman
/// @author daleon
/// @notice KYC is place where user come and fill the kyc details and user can request to view other user's KYC

contract KYC is IKYC, OxAuth {
    /// @notice This mapped the user details according to their address
    mapping(address => Types.UserDetail) private s_userEncryptedInfo;

    /// @notice Mapped hased of User details to its address
    mapping(address => bytes32) private s_hashedData;

    mapping(bytes32 => string) private retrievableData;

    address private immutable nftAddress;

    constructor(address _nftAddress) {
        nftAddress = _nftAddress;
    }

    modifier onlyMinted() {
        if (!INTNFT(nftAddress).hasMinted(msg.sender)) {
            revert KYC__AddressHasNotMinted();
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           SetUserDATA 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice SetUserData is used to set User data and mapped to it address
    /// @param  _name User's Name
    /// @param  _father_name User's Father Name
    /// @param  _mother_name User's Mother Name
    /// @param  _grandFather_name User's GrandFather Name
    /// @param  _phone_number User's Phone_Number details
    /// @param  _dob User's Date of Birth
    /// @param  _blood_group User's Blood Group
    /// @param  _citizenship_number User's CitizenShip_number
    /// @param  _pan_number User's pan Number
    /// @param  _location User's Location
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
    ) external override onlyMinted {
        //mapped deployer address and provide their details
        s_userEncryptedInfo[msg.sender] = Types.UserDetail(
            _name,
            _father_name,
            _mother_name,
            _grandFather_name,
            _phone_number,
            _dob,
            _blood_group,
            _citizenship_number,
            _pan_number,
            _location,
            false
        );
    }

    /*///////////////////////////////////////////////////////////////////////////////
                         GetMessageHash                           
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice GetMessageHash is used to hash User details using Keccak 256
    /// @param dataProviderAddress address of the KycDataProvider
    /// @return bytes32 Keccak256 hash value of the User details
    function getMessageHash(address dataProviderAddress) private view returns (bytes32) {
        // access the struct datatypes from Types.UserDetail

        Types.UserDetail memory userData = s_userEncryptedInfo[dataProviderAddress];

        // perform keccak256 and produce the unique has of represent data

        return
            keccak256(
                abi.encodePacked(
                    userData.name,
                    userData.father_name,
                    userData.mother_name,
                    userData.grandFather_name,
                    userData.phone_number,
                    userData.dob,
                    userData.citizenship_number,
                    userData.pan_number,
                    userData.location
                )
            );
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           getEthSignedMessageHash 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice getEtheSignedMessageHash allows to generate signature that is signed by data Provider Address
    /// @param dataProviderAddress It is address of the User who filled the Kyc details
    /// @dev generate the Signature that proves the particular accound signed the message
    /// @return the Bytes32 address of the signature which represent the address signed the message
    function getEthSignedMessageHash(address dataProviderAddress) private returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        bytes32 data = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                getMessageHash(dataProviderAddress)
            )
        );

        // mapped the bytes32 hashed signature to  data provider address in storage variable

        s_hashedData[dataProviderAddress] = data;

        return data;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                                 generateHash 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice generateHash is call the getEthSignedMessageHash and retun the hashed signature of
    /// @param dataProviderAddress It is address of the User who filled the Kyc details
    /// @return message digest of signature
    function generateHash(address dataProviderAddress) external override returns (bytes32) {
        // call the getEtheSignedMessageHash function and generate Ethereum signed message and KYC details
        return getEthSignedMessageHash(dataProviderAddress);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                                  VERIFY
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice Verify whether the Kyc details is signed by the right DataProviderAddress
    /// @param dataProviderAddress It is address of the User who filled the Kyc details
    /// @return bool true if it signed by correct signer or false
    function verify(
        address dataProviderAddress,
        bytes memory signature
    ) external override returns (bool) {
        // get the ethSignedMessageHash from signer address ie dataProvideraddress
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(dataProviderAddress);

        // Check whethere EthsginedMessageHash and signature represent the rigth Kyc data Provider
        if (recoverSigner(ethSignedMessageHash, signature) == dataProviderAddress) {
            return s_userEncryptedInfo[dataProviderAddress].isVerified = true;
        } else {
            return false;
        }
    }

    /*///////////////////////////////////////////////////////////////////////////////
                              RECOVER Signer 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice recoverSigner allows the SC to validate the incoming data is properly signed
    /// @param _ethSignedMessageHash It is SignedMessageHash of ethereum signature and Kyc details
    /// @param _signature It is the signature of Kyc details signed
    /// @return address is return from ecrecover
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        // seperate into r, s, v to pass in ecrecover
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                              splitSignature
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice splitSignature is used to extract `r`, `s` and `v` values from a signature passed as byte array
    /// @param sig this is signature that represent the exact dataprovider who signed the message
    /// @dev perform signature split r+v+s => r=> 32byte , v=>32byte, s=1byte
    function splitSignature(
        bytes memory sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // require(sig.length == 65, "invalid signature length");
        if (sig.length != 65) {
            revert KYC__INVALIDSignatureLength();
        }

        assembly {
            /*
            First 32 bytes stores the length of the signature
            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature
            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    /*///////////////////////////////////////////////////////////////////////////////
                              getEthHashedData 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice getEthhashedData is getter function which react the hashData from storage variable who is mapped through address
    /// @param dataProviderAddress It is the signer of Kyc data or KYC provider.
    /// @return messageDigest of KYC_details
    function getEthHashedData(
        address dataProviderAddress
    ) external view override returns (bytes32) {
        return s_hashedData[dataProviderAddress];
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Get User Data 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice GEtUserDAta is function which decrypts the AES encrypted data.
    /// @param  dataProvider It is address where dataRequestor is requesting to view the data
    /// @param  data This represent the specific field of KYC form such as name, dob and so forth
    /// @retun return the string datatype of specific field of KYC from

    /// Requestor first need to get approved to view data
    function decryptMyData(
        address dataProvider,
        string calldata data
    ) external view override returns (string memory) {
        require(dataProvider == msg.sender, "KYC__NotOwner");

        if (bytes(data).length == 0) {
            revert("KYC__DataDoesNotExist");
        }

        bytes32 hash = keccak256(bytes(data));
        string memory decryptedData = "";

        if (hash == keccak256(bytes("name"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].name;
        } else if (hash == keccak256(bytes("father_name"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].father_name;
        } else if (hash == keccak256(bytes("mother_name"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].mother_name;
        } else if (hash == keccak256(bytes("grandFather_name"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].grandFather_name;
        } else if (hash == keccak256(bytes("phone_number"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].phone_number;
        } else if (hash == keccak256(bytes("dob"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].dob;
        } else if (hash == keccak256(bytes("blood_group"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].blood_group;
        } else if (hash == keccak256(bytes("citizenship_number"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].citizenship_number;
        } else if (hash == keccak256(bytes("pan_number"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].pan_number;
        } else if (hash == keccak256(bytes("location"))) {
            decryptedData = s_userEncryptedInfo[dataProvider].location;
        } else {
            revert("KYC__DataDoesNotExist");
        }

        if (bytes(decryptedData).length == 0) {
            revert("KYC__DataDoesNotExist");
        }

        return decryptedData;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Update the existing data 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice UpdateKycDetails is function which updatee the specific KYC data.
    /// @param  kycField This represent the specific field of KYC form such as name, dob and so forth
    /// @param  data that need to be update

    function updateKYCDetails(string memory kycField, string memory data) external override {
        bytes32 hash = keccak256(bytes(kycField));
        if (keccak256(bytes("name")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("father_name")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("mother_name")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("grandFather_name")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("phone_number")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("dob")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("blood_group")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("citizenship_number")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("pan_number")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else if (keccak256(bytes("location")) == hash) {
            s_userEncryptedInfo[msg.sender].name = data;
        } else {
            revert KYC__FieldDoesNotExist();
        }
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Storing the RSA encrypted data in the blockchain 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice storeRsaEncryptedinRetrievable is function where data provider encrypts his/her data using requester's public key.
    /// @param dataRequester represents the address of the requester.
    /// @param  kycField This represent the specific field of KYC form such as name, dob and so forth
    /// @param  data represents encrypted data.
    function storeRsaEncryptedinRetrievable(
        address dataRequester,
        string memory kycField,
        string memory data
    ) external {
        bytes32 approveKey = _encodeKey(msg.sender, dataRequester, kycField);
        if (OxAuth._approve[approveKey] == 0) {
            revert KYC__NotYetApprovedToEncryptWithPublicKey();
        }
        bytes32 retrieveKey = _encodeKey(msg.sender, dataRequester, kycField);
        retrievableData[retrieveKey] = data;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Retrieving the Owner's data
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice getRequestedDataFromProvider is function where data requester decrypts data using his/her private key.
    /// @param dataProvider represents the address of the data provider.
    /// @param  kycField This represent the specific field of KYC form such as name, dob and so forth
    function getRequestedDataFromProvider(
        address dataProvider,
        string memory kycField
    ) external view onlyMinted returns (string memory) {
        bytes32 approveKey = _encodeKey(dataProvider, msg.sender, kycField);
        if (OxAuth._approve[approveKey] == 0) {
            revert KYC__NotYetApprovedToView();
        }
        bytes32 key = _encodeKey(dataProvider, msg.sender, kycField);
        return retrievableData[key];
    }
}
