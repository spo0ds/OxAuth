// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IOxAuth {
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

    function requestApproveFromDataProvider(
        address dataProvider,
        string memory data
    ) external;

    function grantAccessToRequester(
        address dataRequester,
        string memory data
    ) external;

    function approveCondition(
        address dataRequester,
        address dataProvider,
        string memory data
    ) external returns (bool);

    // function revokeGrant(
    //     address walletAddress,
    //     address thirdParty,
    //     string memory data
    // ) external;
}
