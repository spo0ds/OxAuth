// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract KycVerification {
    /**@notice Maps the Customer ID to Customer Information
    */
    mapping(bytes32 => Customer) public customers;
    /** @notice Customer overall details later need to add various details;
    *   @dev Customer details
    */
    struct Customer {
        string name;
        string dob;
        string proofofIdentity;
        string proofofAddress;
        bool verified;
    }

    /** @dev gentrate a unique ID for each Customer
    *  we can hash the ecdsa public address with unique key of Customer*
    * @return Keccak256 hash of name and dob
    */
    function generateCustomerUniqueId(
        string memory name,
        string memory dob
        ) 
        public pure returns (bytes32){
        return keccak256(abi.encodePacked(name, dob));
    }

    // /** @notice add new user 
    // * @param name new user name
    // * @param dob date of birth of new user
    // * @param proof of identity of the new user,
    // * @param proof of address of the new user can be wallet address or token id 
    // * @condition => generate new id and check whether generate id is already exists or not
    // */

    function addUser(
    string memory name, 
    string memory dob, 
    string memory proofofIdentity,
    string memory proofofAddress
    ) public {
        bytes32 id = generateCustomerUniqueId(name, dob);

        //check whether User is already exists or not 
        require(!customers[id].verified, "Customer with this Id already exists");

        // If not then create new instance of customer;
        Customer memory customer = Customer({
            name: name,
            dob: dob,
            proofofIdentity: proofofIdentity,
            proofofAddress: proofofAddress,
            verified: false
        });

        customers[id] = customer;
    }

    // /** 
    // @devs verify a customer is true or not
    // */

    function verifyCustomer(bytes32 id) public {
        // check if a customer with this ID Exists
        require(customers[id].verified == false, "Customer witht this ID does not exist");

        // mark the customer as verified
        customers[id].verified = true;
    }

}