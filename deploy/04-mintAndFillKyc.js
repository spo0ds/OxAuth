const { ethers } = require("hardhat")
const { aes } = require("../utils/aes")
const kycContractABI = require("../artifacts/contracts/core/KYC.sol/KYC.json").abi
require("dotenv").config()
const NodeRSA = require("node-rsa")
const { rsaEncrypt, rsaDecrypt } = require("../utils/rsa")

module.exports = async ({ getNamedAccounts, deployments }) => {
    // Getting different accounts to test the functionality of the contracts
    const [owner, from1, from2, from3] = await ethers.getSigners()

    // // Send some Ether to the from1 account
    // await owner.sendTransaction({
    //     to: from1.address,
    //     value: ethers.utils.parseEther("1.0") // Sending 1 Ether
    // })

    // Getting the deployed NTNFT and KYC contracts.
    // The owner account is the deployer of the both contracts.
    const nft = await ethers.getContract("NTNFT", owner)
    const kycDeploy = await ethers.getContract("KYC", owner)

    // Minting the NFT with the owner because then only one can fill the KYC.
    const ownerNftMintTx = await nft.connect(owner).mintNft()
    await ownerNftMintTx.wait()
    console.log(`NFT index ${nft.getTokenCounter()} tokenURI: ${await nft.tokenURI(0)}`)

    const from1NftMintTx = await nft.connect(from1).mintNft()
    await from1NftMintTx.wait()
    console.log(`NFT index ${nft.getTokenCounter()} tokenURI: ${await nft.tokenURI(1)}`)

    // Filling the KYC details for the owner account.
    console.log("Setting user data...")
    const userData = await kycDeploy
        .connect(owner)
        .setUserData(
            aes.encryptMessage("a", "hello"),
            aes.encryptMessage("b", "hello"),
            aes.encryptMessage("c", "hello"),
            aes.encryptMessage("d", "hello"),
            aes.encryptMessage("e", "hello"),
            aes.encryptMessage("f", "hello"),
            aes.encryptMessage("g", "hello"),
            aes.encryptMessage("h", "hello"),
            aes.encryptMessage("i", "hello"),
            aes.encryptMessage("j", "hello")
        )
    console.log(userData)

    // // *** Generate the KYC HASHED DATA ** //
    // console.log("Generating KYC hash......");
    // const userDataHash = await kycDeploy.connect(owner).generateHash(owner.address);
    // console.log(userDataHash);

    // // ** GETTING USER DATA HASH **//
    // console.log("Getting User Hash Data");
    // const getuserDataHash = await kycDeploy.connect(owner).getEthHashedData(owner.address);
    // console.log(getuserDataHash);

    // console.log(" .................................");

    // ** REQUESTING THE KYC FROM ANOTHER ADDRESS **//

    console.log("Requesting the KYC data to view...")
    const [receipt, approveGranted] = await Promise.all([
        kycDeploy.connect(from1).requestApproveFromDataProvider(owner.address, "name"),
        kycDeploy.connect(owner).grantAccessToRequester(from1.address, "name"),
    ])

    // Only Data Provider could view the data
    console.log("Owner views own data:")
    console.log(aes.decryptMessage(await kycDeploy.decryptMyData(owner.address, "name"), "hello"))

    // Generate key pair for user1
    const user1Key = new NodeRSA({ b: 2048 })

    // Using RSA to encrypt the data
    const encryptedData = await rsaEncrypt(user1Key.exportKey("pkcs8-public"), "a")
    console.log(`Encrypted Data:${encryptedData.toString()}`)

    console.log("Store data by encrypting using a public key of the requester...")
    const storeTx = await kycDeploy
        .connect(owner)
        .storeRsaEncryptedinRetrievable(from1.address, "name", encryptedData)
    await storeTx.wait(1)
    console.log(storeTx)

    // Getting Data from Retrievable
    const retrieveData = await kycDeploy
        .connect(from1)
        .getRequestedDataFromProvider(owner.address, "name")
    console.log(`Retirevable Data:${retrieveData}`)
    // console.log("Decrypting data using private key")
    const decryptedMessage = await rsaDecrypt(user1Key.exportKey("pkcs8-private"), retrieveData)
    console.log(`Decrypted Message: ${decryptedMessage}`)
}
