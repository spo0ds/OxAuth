// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IOxAuth.sol";

error OxAuth__OnlyOnceAllowed();
error OxAuth__NotApprover();
error OxAuth__NotApprovedToView();
error OxAuth__TimeFinishedToView();

contract OxAuth is IOxAuth {
    mapping(address => mapping(address => mapping(string => bool)))
        private _Approve;

    enum Status {
        notAsked,
        Asked
    }

    enum dataStatus {
        locked,
        notLocked
    }

    mapping(address => Status) private _ApproveStatus;
    mapping(address => mapping(address => string)) private _RequestedData;
    mapping(address => mapping(string => dataStatus)) private _DataStatus;
    mapping(address => mapping(string => uint)) private _RequestTimeInterval;
    mapping(address => mapping(address => mapping(string => uint)))
        private _StartingTimeInterval;

    modifier onlyOnce() {
        if (_ApproveStatus[msg.sender] == Status.Asked) {
            revert OxAuth__OnlyOnceAllowed();
        }
        _;
    }

    modifier onlyRequestedAccount(address requestAddress, string memory data) {
        if (
            keccak256(
                abi.encodePacked(_RequestedData[msg.sender][requestAddress])
            ) == keccak256(abi.encode(data))
        ) {
            revert OxAuth__NotApprover();
        }
        _;
    }

    modifier onlyAtTime(address walletAddress, string memory data) {
        if (
            block.timestamp >
            _StartingTimeInterval[walletAddress][msg.sender][data]
        ) {
            _Approve[walletAddress][msg.sender][data] = false;
            revert OxAuth__TimeFinishedToView();
        }
        _;
    }

    function requestApprove(
        address walletAddress,
        string memory data,
        uint timePeriod
    ) external override onlyOnce {
        _ApproveStatus[msg.sender] = Status.Asked;
        _RequestedData[msg.sender][walletAddress] = data;
        _RequestTimeInterval[msg.sender][data] = timePeriod;
        emit ApproveRequest(msg.sender, walletAddress, data, timePeriod);
    }

    function grantAccess(
        address approver,
        address thirdParty,
        string memory data
    ) external override onlyOnce onlyRequestedAccount(thirdParty, data) {
        _Approve[approver][thirdParty][data] = true;
        _StartingTimeInterval[approver][thirdParty][data] = block.timestamp;
        emit AccessGrant(
            approver,
            thirdParty,
            data,
            _RequestTimeInterval[thirdParty][data]
        );
    }

    function viewData(
        address walletAddress,
        string memory data
    ) external override onlyAtTime(walletAddress, data) returns (bool) {
        if (_Approve[walletAddress][msg.sender][data] == false) {
            revert OxAuth__NotApprovedToView();
        }
        return true;
    }

    function revokeGrant(
        address thirdParty,
        string memory data
    ) external override onlyRequestedAccount(msg.sender, data) {
        _Approve[msg.sender][thirdParty][data] = false;
        emit GrantRevoke(msg.sender, thirdParty, data);
    }
}
