const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    console.log("Deploying KYC...")
    log("------------------------")
    const nft = await ethers.getContract("NTNFT", deployer)

    const args = [nft.address]
    const kyc = await deploy("KYC", {
        from: deployer,
        args: args,
        logs: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    console.log("Deployed KYC!")
    console.log(`KYC deployed at ${kyc.address}`)

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(kyc.address, args)
    }

    log("--------------------------")
}
