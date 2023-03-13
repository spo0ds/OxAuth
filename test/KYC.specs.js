const { expect } = require("chai")

describe("KYC", function () {
    let kyc
    let nft
    let owner
    let alice
    let user

    beforeEach(async function () {
        const NFT = await ethers.getContractFactory("NTNFT")
        nft = await NFT.deploy()
        const KYC = await ethers.getContractFactory("KYC")
        kyc = await KYC.deploy(nft.address)
        ;[owner, alice, user] = await ethers.getSigners()
        await nft.connect(owner).mintNft()
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

    // describe("getMessageHash", function () {
    //     it("should return the expected message hash", async function () {
    //         const dataProviderAddress = owner.address

    //         await kyc
    //             .connect(owner)
    //             .setUserData(
    //                 "Owner",
    //                 "Bob",
    //                 "Carol",
    //                 "Dave",
    //                 "555-555-1234",
    //                 "01/01/2000",
    //                 "O+",
    //                 "123456789",
    //                 "ABCDE1234F",
    //                 "New York"
    //             )

    //         const retrievedName = await kyc.decryptMyData(owner.address, "name")
    //         const retrievedFatherName = await kyc.decryptMyData(owner.address, "father_name")
    //         const retrievedMotherName = await kyc.decryptMyData(owner.address, "mother_name")
    //         const retrievedGrandFatherName = await kyc.decryptMyData(
    //             owner.address,
    //             "grandFather_name"
    //         )
    //         const retrievedPhoneNumber = await kyc.decryptMyData(owner.address, "phone_number")
    //         const retrievedDob = await kyc.decryptMyData(owner.address, "dob")
    //         const retrievedBloodGroup = await kyc.decryptMyData(owner.address, "blood_group")
    //         const retrievedCitizenshipNumber = await kyc.decryptMyData(
    //             owner.address,
    //             "citizenship_number"
    //         )
    //         const retrievedPanNumber = await kyc.decryptMyData(owner.address, "pan_number")
    //         const retrievedLocation = await kyc.decryptMyData(owner.address, "location")
    //         const expectedHash = ethers.utils.keccak256(
    //             ethers.utils.solidityPack(
    //                 [
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                     "string",
    //                 ],
    //                 [
    //                     retrievedName,
    //                     retrievedFatherName,
    //                     retrievedMotherName,
    //                     retrievedGrandFatherName,
    //                     retrievedPhoneNumber,
    //                     retrievedDob,
    //                     retrievedBloodGroup,
    //                     retrievedCitizenshipNumber,
    //                     retrievedPanNumber,
    //                     retrievedLocation,
    //                 ]
    //             )
    //         )
    //         const messageHash = await kyc.getMessageHash(owner.address)
    //         expect(messageHash).to.equal(expectedHash)
    //     })
    // })

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
            const messageHash = await kyc.getEthHashedData(owner.address)
            const expectedHash = ethers.utils.solidityKeccak256(
                ["bytes"],
                [
                    ethers.utils.concat([
                        keccak256(
                            abi.encodePacked(
                                `\x19Ethereum Signed Message:\n32`,
                                getMessageHash(dataProviderAddress)
                            )
                        ),
                    ]),
                ]
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
