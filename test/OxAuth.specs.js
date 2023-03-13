const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("OxAuth", function () {
    let oxAuth
    let dataProvider
    let dataRequester
    let intruder

    beforeEach(async function () {
        ;[dataProvider, dataRequester, intruder] = await ethers.getSigners()
        const OxAuth = await ethers.getContractFactory("OxAuth")
        oxAuth = await OxAuth.deploy()
        await oxAuth.deployed()
    })

    describe("requestApproveFromDataProvider", function () {
        it("should emit ApproveRequest event", async function () {
            const data = "kyc"
            await expect(
                oxAuth
                    .connect(dataRequester)
                    .requestApproveFromDataProvider(dataProvider.address, data)
            )
                .to.emit(oxAuth, "ApproveRequest")
                .withArgs(dataProvider.address, dataRequester.address, data)
        })
    })

    describe("grantAccessToRequester", function () {
        const data = "kyc"

        beforeEach(async function () {
            await oxAuth
                .connect(dataRequester)
                .requestApproveFromDataProvider(dataProvider.address, data)
            await oxAuth.connect(dataProvider).grantAccessToRequester(dataRequester.address, data)
        })

        it("should emit AccessGrant event", async function () {
            await expect(
                oxAuth.connect(dataProvider).grantAccessToRequester(dataRequester.address, data)
            )
                .to.emit(oxAuth, "AccessGrant")
                .withArgs(dataProvider.address, dataRequester.address, data)
        })

        it("should allow approved requester to access data", async function () {
            expect(
                await oxAuth
                    .connect(dataRequester)
                    .approveCondition(dataRequester.address, dataProvider.address, data)
            ).to.be.true
        })

        it("should not allow non-approved requester to access data", async function () {
            const nonApprovedRequester = ethers.Wallet.createRandom()
            expect(
                await oxAuth.approveCondition(
                    nonApprovedRequester.address,
                    dataProvider.address,
                    data
                )
            ).to.be.false
        })

        // it("should revert if the account is not approved to view", async function () {
        //     // Try to approve condition for data field "phone" using account2, which was not granted access
        //     await expect(
        //         oxAuth.approveCondition(intruder.address, dataProvider.address, "phone")
        //     ).to.be.revertedWith("OxAuth__NotApprovedToView()")
        // })
    })

    describe("approveCondition", function () {
        it("should return true if data requester is approved to view data", async function () {
            // Request approval from data provider for data field "email"
            await oxAuth
                .connect(dataRequester)
                .requestApproveFromDataProvider(dataProvider.address, "data")

            // Grant access to data requester for data field "email"
            await oxAuth.connect(dataProvider).grantAccessToRequester(dataRequester.address, "data")

            // Check if data requester is approved to view data field "email"
            const isApproved = await oxAuth.approveCondition(
                dataRequester.address,
                dataProvider.address,
                "data"
            )
            expect(isApproved).to.be.true
        })

        it("should return false if data requester is not approved to view data", async function () {
            // Request approval from data provider for data field "email"
            await oxAuth
                .connect(dataRequester)
                .requestApproveFromDataProvider(dataProvider.address, "data")

            // Check if data requester is approved to view data field "phone"
            const isApproved = await oxAuth.approveCondition(
                dataRequester.address,
                dataProvider.address,
                "phone"
            )
            expect(isApproved).to.be.false
        })
    })

    describe("revokeGrantToRequester", function () {
        it("should revoke access to requested data field", async function () {
            // Request approval from data provider for data field "email"
            await oxAuth
                .connect(dataRequester)
                .requestApproveFromDataProvider(dataProvider.address, "data")

            // Grant access to data requester for data field "email"
            await oxAuth.connect(dataProvider).grantAccessToRequester(dataRequester.address, "data")

            // Revoke access to data field "email"
            await oxAuth.connect(dataProvider).revokeGrantToRequester(dataRequester.address, "data")

            // Check if data requester is still approved to view data field "email"
            const isApproved = await oxAuth.approveCondition(
                dataRequester.address,
                dataProvider.address,
                "data"
            )
            expect(isApproved).to.be.false
        })

        // it("should revert if requester is not approved to view data", async function () {
        //     // Request approval from data provider for data field "email"
        //     await oxAuth
        //         .connect(dataRequester)
        //         .requestApproveFromDataProvider(dataProvider.address, "data")

        //     // Try to revoke access to data field "phone" using account that was not granted access
        //     await expect(
        //         oxAuth.connect(intruder).revokeGrantToRequester(dataRequester.address, "phone")
        //     ).to.be.revertedWith("OxAuth__NotApprovedToView()")
        // })
    })
})
