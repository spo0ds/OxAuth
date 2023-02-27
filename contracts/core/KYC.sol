// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IKYC.sol";
import "./libraries/Types.sol";
import "./interfaces/IOxAuth.sol";
import "./NTNFT.sol";
import "./OxAuth.sol";

error KYC__INVALIDSignatureLength();
error KYC__CannotViewData();
error KYC__DataDoesNotExist();

contract KYC is IKYC, OxAuth {
    mapping(address => Types.UserDetail) private s_userInfo;
    mapping(address => bytes32) private s_hashedData;

    OxAuth oxAuth;

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

    function getMessageHash(
        address dataProviderAddress
    ) private view returns (bytes32) {
        Types.UserDetail memory userData = s_userInfo[dataProviderAddress];
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
        s_hashedData[dataProviderAddress] = data;

        return data;
    }

    function generateHash(
        address dataProviderAddress
    ) external override returns (bytes32) {
        return getEthSignedMessageHash(dataProviderAddress);
    }

    function verify(
        address dataProviderAddress,
        bytes memory signature
    ) external override returns (bool) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(
            dataProviderAddress
        );
        if (
            recoverSigner(ethSignedMessageHash, signature) ==
            dataProviderAddress
        ) {
            return s_userInfo[dataProviderAddress].isVerified = true;
        } else {
            return false;
        }
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

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

    function getEthHashedData(
        address dataProviderAddress
    ) external view returns (bytes32) {
        return s_hashedData[dataProviderAddress];
    }
}
