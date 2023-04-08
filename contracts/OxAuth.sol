// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IOxAuth} from "./interfaces/IOxAuth.sol";

/*///////////////////////////////////////////////////////////////////////////////
                           CUSTOME ERROR 
//////////////////////////////////////////////////////////////////////////////*/

error OxAuth__OnlyOnceAllowed();
error OxAuth__NotApprover();
error OxAuth__NotApprovedToView();
error OxAuth__TimeFinishedToView();
error OxAuth__NotDataProvider();

/// @title OxAuth
/// @author Spooderman
/// @author daleon
/// @notice OxAuth provider the functionality of authorization and validation to fill and retrieve the data

contract OxAuth is IOxAuth {
    /// @notice this mapped DataProvider address and DataRequestor address and specific data that Viewer want to see
    /// return mapped in bool format
    mapping(address => mapping(address => mapping(string => bool))) internal _Approve;

    // mapped the Requested Data that user want to receieve.
    mapping(address => mapping(address => string)) private _RequestedData;

    /*///////////////////////////////////////////////////////////////////////////////
                           onlyRequestedAccount
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice validation to check whether right caller is right requester
    /// @param requestAddress represent the address who is requesting data from KYC data Provider
    /// @param data represent data field of KYC

    modifier onlyRequestedAccount(address requestAddress, string memory data) {
        // dataMapped store that Keccka256 on the basis of particular KYC data field
        if (
            keccak256(abi.encodePacked(_RequestedData[msg.sender][requestAddress])) ==
            keccak256(abi.encode(data))
        ) {
            // checks the requested data is already mapped or not
            revert OxAuth__NotApprover();
        }
        _;
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
        _RequestedData[dataProvider][msg.sender] = kycField;
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
        if (
            keccak256(abi.encode(_RequestedData[msg.sender][dataRequester])) !=
            keccak256(abi.encode(kycField))
        ) {
            revert OxAuth__NotDataProvider();
        }
        _Approve[msg.sender][dataRequester][kycField] = true;
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
        return _Approve[dataProvider][dataRequester][data];
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
    ) external override onlyRequestedAccount(msg.sender, kycField) {
        _Approve[msg.sender][dataRequester][kycField] = false;
        emit GrantRevoke(msg.sender, dataRequester, kycField);
    }
}
