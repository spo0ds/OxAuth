const { expect, assert } = require("chai")

describe("KYC", function () {
    let kyc
    let nft
    let oxAuth
    let owner
    let alice
    let user

    beforeEach(async function () {
        const NFT = await ethers.getContractFactory("NTNFT")
        nft = await NFT.deploy()
        const KYC = await ethers.getContractFactory("KYC")
        kyc = await KYC.deploy(nft.address)
        const OxAuth = await ethers.getContractFactory("OxAuth")
        oxAuth = await OxAuth.deploy()
        ;[owner, alice, user] = await ethers.getSigners()
        await nft.connect(owner).mintNft()
        await nft.connect(user).mintNft()
    })

    describe("setUserData", function () {
        it("should set the user's encrypted info", async function () {
            const name = "Owner"
            const fatherName = "Bob"
            const motherName = "Carol"
            const grandFatherName = "Dave"
            const phoneNumber = "555-555-1234"
            const dob = "01/01/2000"
            const bloodGroup = "O+"
            const citizenshipNumber = "123456789"
            const panNumber = "ABCDE1234F"
            const location = "New York"

            await kyc
                .connect(owner)
                .setUserData(
                    name,
                    fatherName,
                    motherName,
                    grandFatherName,
                    phoneNumber,
                    dob,
                    bloodGroup,
                    citizenshipNumber,
                    panNumber,
                    location
                )

            const retrievedName = await kyc.decryptMyData(owner.address, "name")
            const retrievedFatherName = await kyc.decryptMyData(owner.address, "father_name")
            const retrievedMotherName = await kyc.decryptMyData(owner.address, "mother_name")
            const retrievedGrandFatherName = await kyc.decryptMyData(
                owner.address,
                "grandFather_name"
            )
            const retrievedPhoneNumber = await kyc.decryptMyData(owner.address, "phone_number")
            const retrievedDob = await kyc.decryptMyData(owner.address, "dob")
            const retrievedBloodGroup = await kyc.decryptMyData(owner.address, "blood_group")
            const retrievedCitizenshipNumber = await kyc.decryptMyData(
                owner.address,
                "citizenship_number"
            )
            const retrievedPanNumber = await kyc.decryptMyData(owner.address, "pan_number")
            const retrievedLocation = await kyc.decryptMyData(owner.address, "location")
            expect(retrievedName).to.equal(name)
            expect(retrievedFatherName).to.equal(fatherName)
            expect(retrievedMotherName).to.equal(motherName)
            expect(retrievedGrandFatherName).to.equal(grandFatherName)
            expect(retrievedPhoneNumber).to.equal(phoneNumber)
            expect(retrievedDob).to.equal(dob)
            expect(retrievedBloodGroup).to.equal(bloodGroup)
            expect(retrievedCitizenshipNumber).to.equal(citizenshipNumber)
            expect(retrievedPanNumber).to.equal(panNumber)
            expect(retrievedLocation).to.equal(location)
        })

        it("should revert if the caller has not minted an NFT", async function () {
            const name = "Alice"
            const fatherName = "Bob"
            const motherName = "Carol"
            const grandFatherName = "Dave"
            const phoneNumber = "555-555-1234"
            const dob = "01/01/2000"
            const bloodGroup = "O+"
            const citizenshipNumber = "123456789"
            const panNumber = "ABCDE1234F"
            const location = "New York"

            await expect(
                kyc
                    .connect(alice)
                    .setUserData(
                        name,
                        fatherName,
                        motherName,
                        grandFatherName,
                        phoneNumber,
                        dob,
                        bloodGroup,
                        citizenshipNumber,
                        panNumber,
                        location
                    )
            ).to.be.revertedWith("KYC__AddressHasNotMinted")
        })
    })

    describe("generateHash", function () {
        it("should return a valid signed message hash", async function () {
            const name = "Owner"
            const fatherName = "Bob"
            const motherName = "Carol"
            const grandFatherName = "Dave"
            const phoneNumber = "555-555-1234"
            const dob = "01/01/2000"
            const citizenshipNumber = "123456789"
            const panNumber = "ABCDE1234F"
            const location = "New York"
            // Set user data
            await kyc
                .connect(owner)
                .setUserData(
                    name,
                    fatherName,
                    motherName,
                    grandFatherName,
                    phoneNumber,
                    dob,
                    citizenshipNumber,
                    panNumber,
                    location,
                    false
                )

            console.log(
                `User data set: ${name}, ${fatherName}, ${motherName}, ${grandFatherName}, ${phoneNumber}, ${dob}, ${citizenshipNumber}, ${panNumber}, ${location}`
            )

            // Generate signed message hash
            const hash = await kyc.generateHash(owner.address)

            console.log(`Signed message hash generated: ${hash}`)

            // Check if the hash is valid
            it("should return the expected hash", async function () {
                // Call the function to get the hash
                const hash = await contractInstance.getEthSignedMessageHash(owner.address)

                // Generate the expected hash
                const messageHash = ethers.utils.solidityKeccak256(["address"], [owner.address])
                const expectedHash = ethers.utils.solidityKeccak256(
                    ["string", "bytes32"],
                    ["\x19Ethereum Signed Message:\n32", messageHash]
                )

                expect(hash).to.equal(expectedHash)

                console.log(`Hash validation passed: ${hash}`)

                // Check if the hash is stored in the contract
                const storedHash = await kyc.getEthHashedData(owner.address)
                expect(storedHash).to.equal(expectedHash)

                console.log(`Hash stored in the contract: ${storedHash}`)
            })

            it("should revert if the caller has not minted an NFT", async function () {
                await expect(kyc.connect(user).generateHash(user.address)).to.be.revertedWith(
                    "KYC: Address has not minted an NFT"
                )

                console.log("Transaction reverted as expected.")
            })
        })
    })

    describe("decryptMyData", function () {
        it("should return the decrypted data for a valid field", async function () {
            await kyc
                .connect(owner)
                .setUserData(
                    "Owner",
                    "Bob",
                    "Carol",
                    "Dave",
                    "555-555-1234",
                    "01/01/2000",
                    "123456789",
                    "ABCDE1234F",
                    "New York",
                    false
                )
            const decryptedName = await kyc.decryptMyData(owner.address, "name")
            const decryptedPhoneNumber = await kyc.decryptMyData(owner.address, "phone_number")

            assert.equal(decryptedName, "Owner")
            assert.equal(decryptedPhoneNumber, "555-555-1234")
        })

        it("should revert for an invalid field", async function () {
            await expect(kyc.decryptMyData(owner.address, "invalid_field")).to.be.revertedWith(
                "KYC__DataDoesNotExist"
            )
        })

        it("should revert if called by someone other than the data provider", async function () {
            await expect(kyc.decryptMyData(user.address, "name")).to.be.revertedWith(
                "KYC__NotOwner"
            )
        })
    })

    describe("updateKYCDetails", function () {
        it("should update the KYC data for a valid field", async function () {
            await kyc.updateKYCDetails("name", "Bob", { from: owner.address })

            const decryptedName = await kyc.decryptMyData(owner.address, "name")

            assert.equal(decryptedName, "Bob")
        })

        it("should revert for an invalid field", async function () {
            await expect(kyc.updateKYCDetails("invalid_field", "data")).to.be.revertedWith(
                "KYC__FieldDoesNotExist"
            )
        })
    })

    describe("storeRsaEncryptedinRetrievable", function () {
        it("should not allow non-approved data provider to store encrypted data", async function () {
            const kycField = "name"
            const data = "0x1234abcd"
            await expect(
                kyc.storeRsaEncryptedinRetrievable(owner.address, kycField, data)
            ).to.be.revertedWith("KYC__NotYetApprovedToEncryptWithPublicKey")
        })

        it("should allow approved data provider to store encrypted data", async function () {
            const kycField = "name"
            await kyc
                .connect(owner)
                .setUserData(
                    "Owner",
                    "Bob",
                    "Carol",
                    "Dave",
                    "555-555-1234",
                    "01/01/2000",
                    "123456789",
                    "ABCDE1234F",
                    "New York",
                    false
                )
            // await kyc.connect(user).requestApproveFromDataProvider(owner.address, kycField)
            // await kyc.connect(owner).grantAccessToRequester(user.address, kycField)
            // await kyc.connect(owner).approveCondition(user.address, owner.address, kycField);

            const rqst = await kyc
                .connect(user)
                .requestApproveFromDataProvider(owner.address, kycField)
            await rqst.wait()

            const approve = await kyc.connect(owner).grantAccessToRequester(user.address, "name")
            await approve.wait()
            await expect(
                kyc.connect(owner).storeRsaEncryptedinRetrievable(user.address, kycField, "Owner")
            ).to.not.be.reverted
            const retrievedData = await kyc
                .connect(user)
                .getRequestedDataFromProvider(owner.address, kycField)
            expect(retrievedData).to.equal("Owner")
        })
    })

    describe("getRequestedDataFromProvider", function () {
        it("should not allow non-approved data requester to retrieve encrypted data", async function () {
            const kycField = "name"
            await expect(
                kyc.getRequestedDataFromProvider(owner.address, kycField)
            ).to.be.revertedWith("KYC__NotYetApprovedToView")
        })

        it("should allow approved data requester to retrieve encrypted data", async function () {
            const kycField = "name"
            await kyc
                .connect(owner)
                .setUserData(
                    "Owner",
                    "Bob",
                    "Carol",
                    "Dave",
                    "555-555-1234",
                    "01/01/2000",
                    "123456789",
                    "ABCDE1234F",
                    "New York",
                    "true"
                )
            await kyc.connect(user).requestApproveFromDataProvider(owner.address, kycField)
            await kyc.connect(owner).grantAccessToRequester(user.address, kycField)
            await kyc.connect(owner).storeRsaEncryptedinRetrievable(user.address, kycField, "owner")
            const retrievedData = await kyc
                .connect(user.address)
                .getRequestedDataFromProvider(owner.address, kycField)
            expect(retrievedData).to.equal("owner")
        })
    })
})
