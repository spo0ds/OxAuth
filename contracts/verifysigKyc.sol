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
        string memory proofofIdentity,
        address to,
        string memory proofofAddress
        ) 
        public pure returns (bytes32){
        return keccak256(abi.encodePacked(proofofIdentity, to, proofofAddress));
    }

   function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address _signer,
        string memory proofofIdentity,
        address to,
        string memory proofofAddress,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = generateCustomerUniqueId(proofofIdentity, to, proofofAddress);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }



    // /** @notice add new user 
    // * @param name new user name
    // * @param dob date of birth of new user
    // * @param proof of identity of the new user,
    // * @param proof of address of the new user can be wallet address or token id 
    // * @condition => generate new id and check whether generate id is already exists or not
    // */

    // function addUser(
    // string memory name, 
    // string memory dob, 
    // string memory proofofIdentity,
    // string memory proofofAddress
    // ) public {
    //     bytes32 id = generateCustomerUniqueId(proofofIdentity, owner, proofofAddress);

    //     //check whether User is already exists or not 
    //     require(!customers[id].verified, "Customer with this Id already exists");

    //     // If not then create new instance of customer;
    //     Customer memory customer = Customer({
    //         name: name,
    //         dob: dob,
    //         proofofIdentity: proofofIdentity,
    //         proofofAddress: proofofAddress,
    //         verified: false
    //     });

    //     customers[id] = customer;
    // }
}