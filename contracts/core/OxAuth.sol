// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./interfaces/IOxAuth.sol";

error OxAuth__OnlyOnceAllowed();
error OxAuth__NotApprover();
error OxAuth__NotApprovedToView();
error OxAuth__TimeFinishedToView();
error OxAuth__NotDataProvider();

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
        address dataProvider,
        string memory data
    ) external {
        _ApproveStatus[dataProvider] = Status.Asked;
        _RequestedData[dataProvider][msg.sender] = data;
        emit ApproveRequest(dataProvider, msg.sender, data);
    }

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
