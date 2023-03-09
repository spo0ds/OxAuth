const { network, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { aes } = require("../utils/aes")
const eccrypto = require("eccrypto")
const kycContractABI = require("../artifacts/contracts/core/KYC.sol/KYC.json").abi;


module.exports = async ({ getNamedAccounts, deployments }) => {
    const [owner, from1, from2, from3] = await ethers.getSigners();

    const nft = await ethers.getContract("NTNFT", owner)
    const nftMintTx = await nft.mintNft()
    await nftMintTx.wait(1)
    console.log(`NFT index 0 tokenURI: ${await nft.tokenURI(0)}`)


    const kycDeploy = await ethers.getContract("KYC", owner)

    console.log("setting user data.....");
    const userData = await kycDeploy.setUserData(aes.encryptMessage("a", "hello"), aes.encryptMessage("b", "hello"), aes.encryptMessage("c", "hello"), aes.encryptMessage("d", "hello"), aes.encryptMessage("e", "hello"), aes.encryptMessage("f", "hello"), aes.encryptMessage("g", "hello"), aes.encryptMessage("h", "hello"), aes.encryptMessage("i", "hello"), aes.encryptMessage("j", "hello"));
    console.log(userData)


    // *** Generate the KYC HASHED DATA ** // 
    console.log("Generating KYC hash......");
    const userDataHash = await kycDeploy.connect(owner).generateHash(owner.address);
    console.log(userDataHash);


    // ** GETTING USER DATA HASH **// 
    console.log("Getting User Hash Data");
    const getuserDataHash = await kycDeploy.connect(owner).getEthHashedData(owner.address);
    console.log(getuserDataHash);

    console.log(" .................................");


    // ** REQUESTING THE KYC FROM ANOTHER ADDRESS **//

    console.log("Requesting the KYC DATA to view");
    const rqst = await kycDeploy.connect(from1).requestApproveFromDataProvider(owner.address, "name");
    console.log(rqst);
    const receipt = await rqst.wait();
    console.log("Receipt", receipt);


    console.log("...........................................");
    // **Granting Access By owner who have signed KYC details *** //
    // throw Gas limit error cause of ABi Code encode method and comparing
    // need to optimize just by removing the abi.encode and hashing comparision solidity code
    console.log("Granting the Requestor to view specific field from kyc ");
    const approve = await kycDeploy.connect(owner).grantAccessToRequester(from1.address, "name");
    await approve.wait();
    console.log(approve);

    console.log("..............................................");


    console.log("Owner view own data")
    const approveGranted = await kycDeploy.connect(owner).getUserData(owner.address, "name")
    console.log(aes.decryptMessage(approveGranted, "hello"))

    var privateKeyB = Buffer.from(process.env.PRIVATE_KEY, 'hex');
    console.log(privateKeyB)
    var publicKeyB = eccrypto.getPublic(privateKeyB);
    console.log(publicKeyB.toString('base64'));

    // Encrypting the message for B.
    const encryptedMessage = await eccrypto.encrypt(publicKeyB, Buffer.from("a"))
    console.log(`Encrypted Message:${encryptedMessage.toString('hex')}`)

    console.log("Store data by encrypting using a public key of the requester")
    const storeTx = await kycDeploy.connect(owner).storeinRetrievable(from1.address, "name", encryptedMessage)
    console.log(storeTx);

    async function decrypt(privateKeyB, encryptedMessage) {
        return await eccrypto.decrypt(privateKeyB, encryptedMessage).then(function (plaintext) {
            return plaintext.toString();
        })
    }

    console.log("Decrypting data using private key")
    const RetrieveTx = await kycDeploy.connect(from1).getUserDataFromRequester(owner.address, "name")
    console.log(await decrypt(privateKeyB, encryptedMessage));

    console.log("============================================")

    console.log("Getting the encrypted data and decrypting it")

    const kycContractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

    // const provider = ethers.provider;
    const kycContract = new ethers.Contract(kycContractAddress, kycContractABI);

    const dataProviderAddress = owner;
    const kycField = "name";
    // const signer = provider.getSigner(from1.address);

    const result = await kycContract.getUserDataFromRequester(dataProviderAddress, kycField, { from: from1 });;
    console.log(await decrypt(privateKeyB, result));
}