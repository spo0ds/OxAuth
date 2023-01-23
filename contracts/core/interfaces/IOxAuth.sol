// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IOxAuth {
    event ApproveRequest(
        address indexed requester,
        address indexed to,
        string indexed data,
        uint timePeriod
    );

    event AccessGrant(
        address indexed approver,
        address indexed thirdParty,
        string indexed data,
        uint timePeriod
    );

    event GrantRevoke(
        address indexed approver,
        address indexed requester,
        string data
    );

    function requestApprove(
        address walletAddress,
        address thirdParty,
        string memory data,
        uint timePeriod
    ) external;

    function grantAccess(
        address approver,
        address thirdParty,
        string memory data
    ) external;

    function viewData(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external returns (bool);

    function revokeGrant(
        address walletAddress,
        address thirdParty,
        string memory data
    ) external;
}
