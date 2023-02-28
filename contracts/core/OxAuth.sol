// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IOxAuth.sol";

error OxAuth__OnlyOnceAllowed();
error OxAuth__NotApprover();
error OxAuth__NotApprovedToView();
error OxAuth__TimeFinishedToView();

contract OxAuth is IOxAuth {
    mapping(address => mapping(address => mapping(string => bool)))
        internal _Approve;

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

    function requestApproveFromDataProvider(
        address dataRequester,
        address dataProvider,
        string memory data
    ) external {
        _ApproveStatus[dataProvider] = Status.Asked;
        _RequestedData[dataProvider][dataRequester] = data;
        emit ApproveRequest(dataProvider, dataRequester, data);
    }

    function grantAccessToRequester(
        address dataProvider,
        address dataRequester,
        string memory data
    )
        external
        override
        /* onlyOnce*/ onlyRequestedAccount(dataRequester, data)
    {
        _Approve[dataProvider][dataRequester][data] = true;
        _StartingTimeInterval[dataProvider][dataRequester][data] = block
            .timestamp;
        emit AccessGrant(dataProvider, dataRequester, data);
    }

    function approveCondition(
        address dataRequester,
        address dataProvider,
        string memory data /*onlyAtTime(walletAddress, data)*/
    ) external view override returns (bool) {
        return _Approve[dataProvider][dataRequester][data];
    }

    function revokeGrant(
        address dataProvider,
        address dataRequester,
        string memory data
    ) external override onlyRequestedAccount(dataProvider, data) {
        _Approve[dataProvider][dataRequester][data] = false;
        emit GrantRevoke(dataProvider, dataRequester, data);
    }
}
