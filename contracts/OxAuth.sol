// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IOxAuth} from "./interfaces/IOxAuth.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error OxAuth__OnlyOnceAllowed();
error OxAuth__NotApprover();
error OxAuth__NotApprovedToView();
error OxAuth__NotDataProvider();

/// @title OxAuth
/// @author Spooderman
/// @author daleon
/// @notice OxAuth provider the functionality of authorization and validation to fill and retrieve the data

contract OxAuth is IOxAuth {
    /// @notice this mapped DataProvider address and DataRequestor address and specific data that Viewer want to see
    /// return mapped in bool format
    mapping(bytes32 => uint256) internal _approve;
    // mapped the Requested Data that user want to receieve.
    mapping(bytes32 => string) private _requestedData;
    /*///////////////////////////////////////////////////////////////////////////////
                           onlyRequestedAccount
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice validation to check whether right caller is right requester
    /// @param requestAddress represent the address who is requesting data from KYC data Provider
    /// @param data represent data field of KYC

    modifier onlyRequestedAccount(address requestAddress, string memory data) {
        bytes32 key = _encodeKey(msg.sender, requestAddress, data);
        require(
            keccak256(abi.encodePacked(_requestedData[key])) == keccak256(abi.encodePacked(data)),
            "OxAuth__NotApprovedToView"
        );
        _;
    }

    function _encodeKey(
        address dataProvider,
        address dataRequester,
        string memory data
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(dataProvider, dataRequester, data));
    }

    function _getBitMask(uint256 bitIndex) private pure returns (uint256) {
        return uint256(1) << bitIndex;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           requestApproveFromDataProvider
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice requestApproveFromDataProvide helps to recieve data ie kyc data from the data Provider
    /// @param dataProvider who represent the address of data Provider who fill the KYC data
    /// @param kycField shows the requested Kyc data field that is requested by data Requestor
    function requestApproveFromDataProvider(
        address dataProvider,
        string memory kycField
    ) external override {
        bytes32 key = _encodeKey(dataProvider, msg.sender, kycField);
        require(bytes(_requestedData[key]).length == 0, "OxAuth__OnlyOnceAllowed");
        _requestedData[key] = kycField;
        emit ApproveRequest(dataProvider, msg.sender, kycField);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           grantAccessToRequestor
    ///////////////////////////////////////////////////////////////////////////////*/

    /// @notice grantAccessToRequester grant the permission to DataRequestor
    /// @param dataRequester address of the dataRequestor
    /// @param kycField represent the data specific Kyc data field that requestor requesting
    function grantAccessToRequester(
        address dataRequester,
        string memory kycField
    ) external override onlyRequestedAccount(dataRequester, kycField) {
        bytes32 key = _encodeKey(msg.sender, dataRequester, kycField);
        uint256 index = uint256(uint8(key[0])) % 32;
        uint256 bitMask = _getBitMask(index);
        _approve[key] |= bitMask;
        emit AccessGrant(msg.sender, dataRequester, kycField);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           approveCondition
    ///////////////////////////////////////////////////////////////////////////////*/

    /// @notice approveCondition is just a getter function to receieve whether it is approved or not
    /// @param dataRequester address of data Requester
    /// @param dataProvider address who provide specific kyc data to requestor
    function approveCondition(
        address dataRequester,
        address dataProvider,
        string memory data
    ) external view override returns (bool) {
        bytes32 key = _encodeKey(dataProvider, dataRequester, data);
        uint256 index = uint256(uint8(key[0])) % 32;
        uint256 bitMask = _getBitMask(index);
        return (_approve[key] & bitMask) != 0;
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           revokeGrantToRequester
    ///////////////////////////////////////////////////////////////////////////////*/

    /// @notice revokeGrantToRequester is a function to revoke the right for the requester to view data.
    /// @param dataRequester address of data Requester
    /// @param kycField represent the Kyc data field that data provider wants to revoke
    function revokeGrantToRequester(
        address dataRequester,
        string memory kycField
    ) external override onlyRequestedAccount(dataRequester, kycField) {
        bytes32 key = _encodeKey(msg.sender, dataRequester, kycField);
        uint256 index = uint256(uint8(key[0])) % 32;
        uint256 bitMask = _getBitMask(index);
        _approve[key] &= ~bitMask;
        emit GrantRevoke(msg.sender, dataRequester, kycField);
    }
}
