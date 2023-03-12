// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IRouter.sol";
import "../core/interfaces/INTNFT.sol";
import "../core/interfaces/IKYC.sol";
import "../core/interfaces/IOxAuth.sol";

contract Router is IRouter {
    address private immutable nftAddress;
    address private immutable kycAddress;
    address private immutable oxAuthAddress;

    constructor(
        address _nftAddress,
        address _kycAddress,
        address _oxAuthAddress
    ) {
        nftAddress = _nftAddress;
        kycAddress = _kycAddress;
        oxAuthAddress = _oxAuthAddress;
    }

    function getNft() public override returns (uint) {
        return INTNFT(nftAddress).mintNft();
    }

    function burnNft(uint tokenId) public override {
        INTNFT(nftAddress).burn(tokenId);
    }

    // function revokeNft(uint tokenId) public override {
    //     INTNFT(nftAddress).revoke(tokenId);
    // }

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
    ) public override {
        IKYC(kycAddress).setUserData(
            _name,
            _father_name,
            _mother_name,
            _grandFather_name,
            _phone_number,
            _dob,
            _blood_group,
            _citizenship_number,
            _pan_number,
            _location
        );
    }

    function getHash(address walletAddress) public override returns (bytes32) {
        return IKYC(kycAddress).generateHash(walletAddress);
    }

    function verifySignature(
        address walletAddress,
        bytes memory signature
    ) public override {
        IKYC(kycAddress).verify(walletAddress, signature);
    }

    function requestDataFromOtherAddress(
        address walletAddress,
        string memory data
    ) public override {
        IOxAuth(oxAuthAddress).requestApproveFromDataProvider(
            walletAddress,
            data
        );
    }

    function approveOthersRequest(
        address thirdParty,
        string memory data
    ) public override {
        IOxAuth(oxAuthAddress).grantAccessToRequester(thirdParty, data);
    }
}
