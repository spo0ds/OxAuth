const ethers = require("ethers")

const getcontractObj = (function (provider, contractABI, contractAddress) {
    // // create a provider object (e.g. connecting to the Ethereum mainnet)
    // const provider = new ethers.providers.InfuraProvider('mainnet', 'YOUR_INFURA_PROJECT_ID');

    // // create an instance of the contract (e.g. using its ABI and address)
    // const contractABI = [ /* insert your contract ABI here */];
    // const contractAddress = '0x...'; // insert your contract address here
    const contract = new ethers.Contract(contractAddress, contractABI, provider)

    // call the contract function and get the returned object
    // const result = await contract.myFunction(param1, param2, ...);
    // console.log(result);
    return contract
})()

module.exports = {
    getcontractObj,
}
