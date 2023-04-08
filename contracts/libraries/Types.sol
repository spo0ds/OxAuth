// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

library Types {
    struct UserDetail {
        string name;
        string father_name;
        string mother_name;
        string grandFather_name;
        string phone_number;
        string dob;
        string blood_group;
        string citizenship_number;
        string pan_number;
        string location;
        bool isVerified;
    }
}
