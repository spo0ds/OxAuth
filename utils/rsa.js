var RSA = require('hybrid-crypto-js').RSA;
var Crypt = require('hybrid-crypto-js').Crypt;

const rsa = (function () {
    // Basic initialization
    var crypt = new Crypt();
    var rsa = new RSA();

    // Select default message digest
    var crypt = new Crypt({ md: 'sha512' });

    // Select AES or RSA standard
    var crypt = new Crypt({
        // Default AES standard is AES-CBC. Options are:
        // AES-ECB, AES-CBC, AES-CFB, AES-OFB, AES-CTR, AES-GCM, 3DES-ECB, 3DES-CBC, DES-ECB, DES-CBC
        aesStandard: 'AES-CBC',
        // Default RSA standard is RSA-OAEP. Options are:
        // RSA-OAEP, RSAES-PKCS1-V1_5
        rsaStandard: 'RSA-OAEP',
    });

    return {
        encryptMessage: function (messageToencrypt = '', publicKey = '') {
            var encryptedMessage = crypt.encrypt(publicKey, messageToencrypt);;
            return encryptedMessage.toString();
        },
        decryptMessage: function (encryptedMessage = '', privateKey = '') {
            var decryptedBytes = crypt.decrypt(privateKey, encryptedMessage);;
            var decryptedMessage = decryptedBytes.toString(CryptoJS.enc.Utf8);

            return decryptedMessage;

        }
    }
})();

module.exports = {
    rsa,
}