// const { expect, assert } = require("chai")
// const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers")
// const { ethers } = require("hardhat")

// describe("NTNFT Contract", () => {
//     let accounts, deployer, nft

//     async function deployNftFixture() {
//         const nftContract = await ethers.getContractFactory("NTNFT")
//         nft = await nftContract.deploy()
//         await nft.deployed()

//         return {
//             nft,
//         }
//     }

//     beforeEach(async () => {
//         accounts = await ethers.getSigners()
//         deployer = accounts[0].address
//         const { nft } = await loadFixture(deployNftFixture)
//     })

//     describe("Mint NFT", () => {
//         it("Allows users to mint an NFT, and updates appropriately", async function () {
//             const txResponse = await nft.mintNft()
//             await txResponse.wait(1)
//             const tokenURI = await nft.tokenURI(0)
//             const tokenCounter = await nft.getTokenCounter()
//             const hasMinted = await nft.hasMinted(deployer)
//             assert.equal(tokenCounter.toString(), "1")
//             assert.isTrue(hasMinted)
//         })

//         it("Doesn't allow user to mint more than once", async function () {
//             await nft.mintNft()
//             await expect(nft.mintNft()).to.be.revertedWith("NTNFT__CanOnlyMintOnce")
//         })
//     })

//     describe("Burn NFT", () => {
//         it("Allows users to burn an NFT", async function () {
//             await nft.mintNft()
//             const tokenId = 0
//             const txResponse = await nft.burn(tokenId)
//             await txResponse.wait(1)
//             const hasMinted = await nft.hasMinted(deployer)
//             assert.isFalse(hasMinted)
//         })

//         it("Doesn't allow user to burn NFT they don't own", async function () {
//             await nft.mintNft()
//             const tokenId = 0
//             const burner = accounts[1]
//             await expect(nft.connect(burner).burn(tokenId)).to.be.revertedWith(
//                 "NTNFT__NftNotTransferrable"
//             )
//         })
//     })

//     // describe("SafeTransferFrom", () => {
//     //     it("Doesn't allow safeTransferFrom", async function () {
//     //         const receiver = accounts[1].address
//     //         const tokenId = 0
//     //         await expect(nft.safeTransferFrom(deployer, receiver, tokenId)).to.be.revertedWith(
//     //             "NTNFT__NftNotTransferrable"
//     //         )
//     //     })
//     // })

//     describe("TransferFrom", () => {
//         it("Doesn't allow transferFrom", async function () {
//             const receiver = accounts[1].address
//             const tokenId = 0
//             await expect(nft.transferFrom(deployer, receiver, tokenId)).to.be.revertedWith(
//                 "NTNFT__NftNotTransferrable"
//             )
//         })
//     })

//     describe("Approve", () => {
//         it("Doesn't allow approve", async function () {
//             const receiver = accounts[1].address
//             const tokenId = 0
//             await expect(nft.approve(receiver, tokenId)).to.be.revertedWith(
//                 "NTNFT__NftNotTransferrable"
//             )
//         })
//     })

//     describe("setApprovalForAll", () => {
//         it("throws an error when trying to approve transfer for a soulbound NFT", async function () {
//             await expect(nft.setApprovalForAll(accounts[1].address, true)).to.be.revertedWith(
//                 "NTNFT__NftNotTransferrable"
//             )
//         })
//     })

//     describe("getApproved", () => {
//         it("throws an error when trying to get approved address for a soulbound NFT", async function () {
//             await expect(nft.getApproved(0)).to.be.revertedWith("NTNFT__NftNotTransferrable")
//         })
//     })

//     describe("isApprovedForAll", () => {
//         it("throws an error when trying to get approved status for a soulbound NFT", async function () {
//             await expect(
//                 nft.isApprovedForAll(accounts[0].address, accounts[1].address)
//             ).to.be.revertedWith("NTNFT__NftNotTransferrable")
//         })
//     })
// })
