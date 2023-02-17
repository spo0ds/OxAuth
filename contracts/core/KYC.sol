// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IKYC.sol";
import "./libraries/Types.sol";
import "./interfaces/IOxAuth.sol";

error KYC__INVALIDSignatureLength();
error KYC__CannotViewData();
error KYC__DataDoesNotExist();

contract KYC is IKYC {
    mapping(address => Types.UserDetail) private s_userInfo;
    mapping(address => bytes32) private s_hashedData;
    address private immutable oxAuthAddress;

    constructor(address _oxAuthAddress) {
        oxAuthAddress = _oxAuthAddress;
    }

    function getUserData(
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
        address walletAddress
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    s_userInfo[walletAddress].name,
                    s_userInfo[walletAddress].father_name,
                    s_userInfo[walletAddress].mother_name,
                    s_userInfo[walletAddress].grandFather_name,
                    s_userInfo[walletAddress].phone_number,
                    s_userInfo[walletAddress].dob,
                    s_userInfo[walletAddress].citizenship_number,
                    s_userInfo[walletAddress].pan_number,
                    s_userInfo[walletAddress].location
                )
            );
    }

    function getEthSignedMessageHash(
        address walletAddress
    ) internal returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            s_hashedData[walletAddress] = keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    getMessageHash(walletAddress)
                )
            );
    }

    function generateHash(
        address walletAddress
    ) external override returns (bytes32) {
        return getEthSignedMessageHash(walletAddress);
    }

    function verify(
        address walletAddress,
        bytes memory signature
    ) external override returns (bool) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(walletAddress);
        if (recoverSigner(ethSignedMessageHash, signature) == walletAddress) {
            return s_userInfo[walletAddress].isVerified = true;
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
        address walletAddress
    ) external view returns (bytes32) {
        return s_hashedData[walletAddress];
    }

    function requestForApproval(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external override {
        IOxAuth(oxAuthAddress).requestApprove(walletAddress, thirdParty, data);
    }

    function grantTheRequest(
        address approver,
        address thirdParty,
        string memory data
    ) external override {
        IOxAuth(oxAuthAddress).grantAccess(approver, thirdParty, data);
    }

    // still remaining
    function displayData(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external override {
        if (!IOxAuth(oxAuthAddress).viewData(walletAddress, thirdParty, data)) {
            revert KYC__CannotViewData();
        }
        string memory userData;
        if (keccak256(abi.encode("name")) == keccak256(abi.encode(data))) {
            userData = s_userInfo[walletAddress].name;
        }
        if (
            keccak256(abi.encode("father_name")) == keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].father_name;
        }
        if (
            keccak256(abi.encode("mother_name")) == keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].mother_name;
        }
        if (
            keccak256(abi.encode("grandFather_name")) ==
            keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].grandFather_name;
        }
        if (
            keccak256(abi.encode("phone_number")) == keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].phone_number;
        }
        if (keccak256(abi.encode("dob")) == keccak256(abi.encode(data))) {
            userData = s_userInfo[walletAddress].dob;
        }
        if (
            keccak256(abi.encode("blood_group")) == keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].blood_group;
        }
        if (
            keccak256(abi.encode("citizenship_number")) ==
            keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].citizenship_number;
        }
        if (
            keccak256(abi.encode("pan_number")) == keccak256(abi.encode(data))
        ) {
            userData = s_userInfo[walletAddress].pan_number;
        }
        if (keccak256(abi.encode("location")) == keccak256(abi.encode(data))) {
            userData = s_userInfo[walletAddress].location;
        } else {
            revert KYC__DataDoesNotExist();
        }
    }

    function revokeApprove(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external override {
        IOxAuth(oxAuthAddress).revokeGrant(walletAddress, thirdParty, data);
    }
}
