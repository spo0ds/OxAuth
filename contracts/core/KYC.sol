// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IKYC} from "./interfaces/IKYC.sol";
import {Types} from "./libraries/Types.sol";
import {IOxAuth} from "./interfaces/IOxAuth.sol";
import {OxAuth} from "./OxAuth.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error KYC__INVALIDSignatureLength();
error KYC__CannotViewData();
error KYC__DataDoesNotExist();
error KYC__FieldDoesNotExist();

/// @title KYC Interaction
/// @author Spooderman
/// @author daleon
/// @notice KYC is place where user come and fill the kyc details and user can request to view other user's KYC

contract KYC is IKYC, OxAuth {
    /// @notice This mapped the user details according to their address
    mapping(address => Types.UserDetail) private s_userInfo;

    /// @notice Mapped hased of User details to its address
    mapping(address => bytes32) private s_hashedData;

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
    ) external {
        //mapped deployer address and provide their details

        s_userInfo[msg.sender] = Types.UserDetail(
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
    function getMessageHash(
        address dataProviderAddress
    ) private view returns (bytes32) {
        // access the struct datatypes from Types.UserDetail

        Types.UserDetail memory userData = s_userInfo[dataProviderAddress];

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
    function getEthSignedMessageHash(
        address dataProviderAddress
    ) private returns (bytes32) {
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
    function generateHash(
        address dataProviderAddress
    ) external override returns (bytes32) {
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
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(
            dataProviderAddress
        );

        // Check whethere EthsginedMessageHash and signature represent the rigth Kyc data Provider
        if (
            recoverSigner(ethSignedMessageHash, signature) ==
            dataProviderAddress
        ) {
            return s_userInfo[dataProviderAddress].isVerified = true;
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
                              RECOVER Signer 
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
                              RECOVER Signer 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice getEthhashedData is getter function which react the hashData from storage variable who is mapped through address
    /// @param dataProviderAddress It is the signer of Kyc data or KYC provider.
    /// @return messageDigest of KYC_details
    function getEthHashedData(
        address dataProviderAddress
    ) external view returns (bytes32) {
        return s_hashedData[dataProviderAddress];
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Get User Data 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice GEtUserDAta is function which provide the specific KYC datg to user who request to See Details.
    /// @param  dataProvider It is address where dataRequestor is requesting to view the data
    /// @param  data This represent the specific field of KYC form such as name, dob and so forth
    /// @retun return the string datatype of specific field of KYC from

    /// Requestor first need to get approved to view data
    function getUserData(
        address dataProvider,
        string memory data
    ) external view returns (string memory) {
        require(
            OxAuth._Approve[dataProvider][msg.sender][data] == true,
            "not access yet"
        );

        if (keccak256(abi.encode("name")) == keccak256(abi.encode(data))) {
            return s_userInfo[dataProvider].name;
        } else if (
            keccak256(abi.encode("father_name")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].father_name;
        } else if (
            keccak256(abi.encode("mother_name")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].mother_name;
        } else if (
            keccak256(abi.encode("grandFather_name")) ==
            keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].grandFather_name;
        } else if (
            keccak256(abi.encode("phone_number")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].phone_number;
        } else if (
            keccak256(abi.encode("dob")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].dob;
        } else if (
            keccak256(abi.encode("blood_group")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].blood_group;
        } else if (
            keccak256(abi.encode("citizenship_number")) ==
            keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].citizenship_number;
        } else if (
            keccak256(abi.encode("pan_number")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].pan_number;
        } else if (
            keccak256(abi.encode("location")) == keccak256(abi.encode(data))
        ) {
            return s_userInfo[dataProvider].location;
        } else {
            revert KYC__DataDoesNotExist();
        }
    }

    /*///////////////////////////////////////////////////////////////////////////////
                               Update the existing data 
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice UpdateKycDetails is function which updatee the specific KYC data .
    /// @param  kycField This represent the specific field of KYC form such as name, dob and so forth
    /// @param  data that need to be update

    function updateKYCDetails(
        string memory kycField,
        string memory data
    ) external {
        if (keccak256(abi.encode("name")) == keccak256(abi.encode(kycField))) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("father_name")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("mother_name")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("grandFather_name")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("phone_number")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("dob")) == keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("blood_group")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("citizenship_number")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("pan_number")) ==
            keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else if (
            keccak256(abi.encode("location")) == keccak256(abi.encode(kycField))
        ) {
            s_userInfo[msg.sender].name = data;
        } else {
            revert KYC__FieldDoesNotExist();
        }
    }
}
