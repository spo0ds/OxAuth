let CryptoJS = require("crypto-js")

const aes = (function () {
    return {
        encryptMessage: function (messageToencrypt = '', secretkey = '') {
            var encryptedMessage = CryptoJS.AES.encrypt(messageToencrypt, secretkey);
            return encryptedMessage.toString();
        },
        decryptMessage: function (encryptedMessage = '', secretkey = '') {
            var decryptedBytes = CryptoJS.AES.decrypt(encryptedMessage, secretkey);
            var decryptedMessage = decryptedBytes.toString(CryptoJS.enc.Utf8);

            return decryptedMessage;
        }
    }
})();

module.exports = {
    aes,
}