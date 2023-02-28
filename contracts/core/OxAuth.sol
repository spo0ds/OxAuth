// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import  {IOxAuth} from "./interfaces/IOxAuth.sol";


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

    // check mapped data being asked or not asked through enum
    // enum Status {
    //     notAsked,
    //     Asked
    // }

    // check whether data is already send to data Requestor 
    // Implemenation for Further use

    // enum dataStatus {
    //     locked,
    //     notLocked
    // }

    /// mapped the address of and status of data that has been asked
    /// mapping(address => Status) private _ApproveStatus;

    // mapped the Requested Data that user want to receieve.
    mapping(address => mapping(address => string)) private _RequestedData;

    // mapped Data status to prevent the duplication of data when requesting data
    // mapping(address => mapping(string => dataStatus)) private _DataStatus;

    /// mapped the timeInterval when data is requested

    //mapping(address => mapping(string => uint)) private _RequestTimeInterval;
    //mapping(address => mapping(address => mapping(string => uint))) private _StartingTimeInterval;

    // modifier onlyOnce() {
    //     if (_ApproveStatus[msg.sender] == Status.Asked) {
    //         revert OxAuth__OnlyOnceAllowed();
    //     }
    //     _;
    // }


    /*///////////////////////////////////////////////////////////////////////////////
                           onlyRequestedAccount
    //////////////////////////////////////////////////////////////////////////////*/


    /// @notice validation to check whether right caller is right requester
    /// @param requestAddress represent the address who is requesting data from KYC data Provider
    /// @param data represent data field of KYC 

    modifier onlyRequestedAccount(address requestAddress, string memory data) {

        // dataMapped store that Keccka256 on the basis of particular KYC data field
        bytes memory dataMapped = keccak256(abi.encodePacked(_RequestedData[msg.sender][requestAddress]);
        bytes memory dataAsked = keccak256(abi.encode(data);

        // checks the requested data is already mapped or not
        if (dataMapped == dataAsked) revert OxAuth__NotApprover();
        _;
    }


    /*///////////////////////////////////////////////////////////////////////////////
                           onlyRequestedAccount
    //////////////////////////////////////////////////////////////////////////////*/

    /// @notice requestApproveFromDataProvide helps to recieve the requestor
    /// @param dataProvider who represent the address of data Provider that Data Requestor is requesting 
    /// @param data shows the requested Kyc field data from data Requestor
    function requestApproveFromDataProvider(
        address dataProvider,
        string memory data
    ) external {
        RequestedData[dataProvider][msg.sender] = data;
        emit ApproveRequest(dataProvider, msg.sender, data);
    }
    

    /*///////////////////////////////////////////////////////////////////////////////
                           grantAccessToRequestor
    ///////////////////////////////////////////////////////////////////////////////*/

    /// @notice grantAccessToRequester grant the permission to DataRequestor
    /// @param dataRequester address of the dataRequestor
    /// @param data represent the data specific Kyc data field that requestor requesting   
    function grantAccessToRequester(
        address dataRequester,
        string memory data
    )
        external
        override
        /* onlyOnce*/ onlyRequestedAccount(dataRequester, data)
    {
        if (
            keccak256(abi.encode(_RequestedData[msg.sender][dataRequester])) !=
            keccak256(abi.encode(data))
        ) {
            revert OxAuth__NotDataProvider();
        }
        _Approve[msg.sender][dataRequester][data] = true;
        // _StartingTimeInterval[dataProvider][dataRequester][data] = block
        //     .timestamp;
        emit AccessGrant(msg.sender, dataRequester, data);
    }

    /*///////////////////////////////////////////////////////////////////////////////
                           grantAccessToRequestor
    ///////////////////////////////////////////////////////////////////////////////*/

    /// @notice approveCondition is just a getter function to receieve whether it is approved or not 
    /// @param dataRequester address of data Requester
    /// @param dataProvider address who provide specific kyc data to requestor
    function approveCondition(
        address dataRequester,
        address dataProvider,
        string memory data /*onlyAtTime(walletAddress, data)*/
    ) external view override returns (bool) {
        return _Approve[dataProvider][dataRequester][data];
    }

    // function revokeGrant(
    //     address dataProvider,
    //     address dataRequester,
    //     string memory data
    // ) external override onlyRequestedAccount(dataProvider, data) {
    //     _Approve[dataProvider][dataRequester][data] = false;
    //     emit GrantRevoke(dataProvider, dataRequester, data);
    // }
}
