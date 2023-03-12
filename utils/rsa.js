const NodeRSA = require("node-rsa")

const rsaEncrypt = async function encrypt(key, message) {
    const rsaKey = new NodeRSA()
    rsaKey.importKey(key, "pkcs8-public")
    return rsaKey.encrypt(message, "base64")
}

const rsaDecrypt = async function decrypt(key, encryptedMessage) {
    const rsaKey = new NodeRSA()
    rsaKey.importKey(key, "pkcs8-private")
    return rsaKey.decrypt(encryptedMessage, "utf8")
}

module.exports = {
    rsaEncrypt,
    rsaDecrypt,
}
