const { expect, assert } = require("chai")
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")
const { ethers } = require("hardhat")

describe("NTNFT Contract", () => {
    let accounts, deployer, nft

    async function deployNftFixture() {
        const nftContract = await ethers.getContractFactory("NtNft")
        nft = await nftContract.deploy()
        await nft.deployed()

        return {
            nft,
        }
    }

    describe("Mint NFT", () => {
        async function mintFixture() {
            accounts = await ethers.getSigners()
            deployer = accounts[0].address
            const { nft } = await loadFixture(deployNftFixture)
            const txResponse = await nft.mintNft(deployer)
            await txResponse.wait(1)
        }

        it("Allows users to mint an NFT, and updates appropriately", async function () {
            await loadFixture(mintFixture)
            const tokenURI = await nft.tokenURI(0)
            const tokenCounter = await nft.getTokenCounter()
            assert.equal(tokenCounter.toString(), "1")
        })
    })
})
