const { expect } = require("chai")
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")
const { ethers } = require("hardhat")
describe("NTNFT Contract", () => {
    async function deployNftFixture() {

        const nftContract = await ethers.getContractFactory("NTNFT")
        const nft = await nftContract.deploy()
        await nft.deployed()

        return {
            nft
        }
    }

    describe("Mint an NFT", () => {
        it("after the mint, it should increase the token counter of the NFT", async () => {
            const { nft } = await loadFixture(deployNftFixture)
            const { oldTokenCounter } = await nft.getTokenCounter()
            const txResponse = await nft.mintNft()
            await txResponse.wait(1)
            const { newTokenCounter } = await nft.getTokenCounter()
            expect(newTokenCounter?.toString()).eq("1");
            expect(oldTokenCounter?.toString()).eq("0");
        })
    })
}) 