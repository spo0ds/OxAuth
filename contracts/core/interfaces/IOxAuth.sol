// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IOxAuth {
    /*///////////////////////////////////////////////////////////////////////////////
                           Events
    //////////////////////////////////////////////////////////////////////////////*/
    event ApproveRequest(
        address indexed requester,
        address indexed to,
        string indexed data
    );

    event AccessGrant(
        address indexed approver,
        address indexed thirdParty,
        string indexed data
    );

    event GrantRevoke(
        address indexed approver,
        address indexed requester,
        string data
    );

    /// @notice requestApproveFromDataProvide helps to recieve data ie kyc data from the data Provider
    function requestApproveFromDataProvider(
        address dataProvider,
        string memory data
    ) external;

    /// @notice grantAccessToRequester grant the permission to DataRequestor
    function grantAccessToRequester(
        address dataRequester,
        string memory data
    ) external;

    /// @notice approveCondition is just a getter function to receieve whether it is approved or not
    function approveCondition(
        address dataRequester,
        address dataProvider,
        string memory data
    ) external returns (bool);

    function revokeGrantToRequester(
        address dataRequester,
        string memory kycField
    ) external;
}
