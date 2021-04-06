const createHmac = require("create-hmac");
const ecc = require("tiny-secp256k1");
const bs58check = require("bs58check");
const HIGHEST_BIT = Math.pow(2, 31);
const pathRegex = new RegExp(/^(m\/)?(\d+'?\/)*\d+'?$/);
function hmacSHA512(data, key = keyValue) {
  return createHmac("sha512", key).update(data).digest();
}
function BIP32(privKey, pubKey, chainCode, index) {
  this.privKey = privKey;
  this.pubKey = pubKey;
  this.chainCode = chainCode;
  this.index = index;

  this.getBip32 = () => {
    return {
      privKey: this.privKey,
      pubKey: this.pubKey || this.getPubKey(),
      chainCode: this.chainCode,
      index: this.index,
    };
  };

  this.getExtendedKeys = () => {
    const encoded = Buffer.allocUnsafe(65);
    if (!this.isPrivKey()) {
      encoded[0] = 0x00;
      this.privKey.forEach((element, i) => {
        encoded[i + 1] = element;
      });
      this.chainCode.forEach((element, i) => {
        encoded[i + 33] = element;
      });
    } else {
      const pubkey = this.getPubKey();
      pubkey.forEach((element, i) => {
        encoded[i] = element;
      });
      this.chainCode.forEach((element, i) => {
        encoded[i + 33] = element;
      });
    }
    return bs58check.encode(encoded);
  };

  this.getPubKey = () => {
    if (this.pubKey === undefined) {
      return ecc.pointFromScalar(this.privKey, true);
    }
    return this.pubKey;
  };

  this.isPrivKey = () => {
    return this.privKey === undefined;
  };

  this.derive = (index) => {
    const isHardened = index >= HIGHEST_BIT;
    const data = Buffer.allocUnsafe(37);
    if (isHardened) {
      if (this.isPrivKey())
        throw new Error("Missing private key for hardened child key");

      data[0] = 0x00;
      this.privKey.forEach((element, i) => {
        data[i + 1] = element;
      });
      data.writeUInt32BE(index, 33);
    } else {
      let pubKey = this.pubKey;
      if (!pubKey) pubKey = this.getPubKey();
      pubKey.forEach((element, i) => {
        data[i] = element;
      });
      data.writeUInt32BE(index, 33);
    }
    const sha = hmacSHA512(this.chainCode, data);
    const IL = sha.slice(0, 32);
    const IR = sha.slice(32);
    if (!ecc.isPrivate(IL)) return this.derive(index + 1);
    let hd;
    if (!this.isPrivKey()) {
      const ki = ecc.privateAdd(this.privKey, IL);
      if (ki == null) return this.derive(index + 1);
      hd = fromPrivateKey(ki, IR, index);
    } else {
      let pubKey = this.pubKey;

      if (!pubKey) pubKey = this.getPubKey();

      const Ki = ecc.pointAddScalar(pubKey, IL, true);
      if (Ki === null) return this.derive(index + 1);
      hd = fromPublicKey(Ki, IR, index);
    }
    return hd;
  };

  this.derivePath = (path) => {
    if (!pathRegex.test(path)) throw new Error("Path is wrong");
    let splitPath = path.split("/");
    if (splitPath[0] === "m") {
      splitPath = splitPath.slice(1);
    }
    return splitPath.reduce((prevHd, indexStr) => {
      let index;
      if (indexStr.slice(-1) === `'`) {
        index = parseInt(indexStr.slice(0, -1), 10);
        return prevHd.derive(index + HIGHEST_BIT);
      } else {
        index = parseInt(indexStr, 10);
        return prevHd.derive(index);
      }
    }, this);
  };
}

function fromSeed(seed) {
  const sha = hmacSHA512(Buffer.from("Bitcoin seed", "utf8"), seed);
  const privateKey = sha.slice(0, 32);
  const chainCode = sha.slice(32);
  return fromPrivateKey(privateKey, chainCode, undefined);
}

function fromPrivateKey(privateKey, chainCode, index) {
  if (!ecc.isPrivate(privateKey))
    throw new Error("Private key not in range [1, n)");
  return new BIP32(privateKey, undefined, chainCode, index);
}

function fromPublicKey(publicKey, chainCode, index) {
  if (!ecc.isPoint(publicKey)) throw new Error("Point is not on the curve");
  return new BIP32(undefined, publicKey, chainCode, index);
}
module.exports = {
  fromSeed,
};
