### Files Description Table

| File Name              | SHA-1 Hash                               |
| ---------------------- | ---------------------------------------- |
| contracts/core/KYC.sol | 0487a83203ba82ecc495531f7083917ca939c4a4 |

### Contracts Description Table

| Contract |              Type              |     Bases      |                |               |
| :------: | :----------------------------: | :------------: | :------------: | :-----------: |
|    └     |       **Function Name**        | **Visibility** | **Mutability** | **Modifiers** |
|          |                                |                |                |               |
| **KYC**  |         Implementation         |  IKYC, OxAuth  |                |               |
|    └     |         <Constructor>          |   Public ❗️   |       🛑       |     NO❗️     |
|    └     |          setUserData           |  External ❗️  |       🛑       |  onlyMinted   |
|    └     |         getMessageHash         |   Private 🔐   |                |               |
|    └     |    getEthSignedMessageHash     |   Private 🔐   |       🛑       |               |
|    └     |          generateHash          |  External ❗️  |       🛑       |     NO❗️     |
|    └     |             verify             |  External ❗️  |       🛑       |     NO❗️     |
|    └     |         recoverSigner          |  Internal 🔒   |                |               |
|    └     |         splitSignature         |  Internal 🔒   |                |               |
|    └     |        getEthHashedData        |  External ❗️  |                |     NO❗️     |
|    └     |         decryptMyData          |  External ❗️  |                |     NO❗️     |
|    └     |        updateKYCDetails        |  External ❗️  |       🛑       |     NO❗️     |
|    └     | storeRsaEncryptedinRetrievable |  External ❗️  |       🛑       |     NO❗️     |
|    └     |  getRequestedDataFromProvider  |  External ❗️  |                |  onlyMinted   |

### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑   | Function can modify state |
|   💵   | Function is payable       |
