const pbkdf2 = require("pbkdf2");
const wordlist = require("./wordList.json");
const createHash = require("create-hash");
const randomBytes = require("randombytes");

let BIP39 = {
  entropyToMnemonic: function (entropy) {
    if (
      entropy.length < 16 ||
      entropy.length > 32 ||
      entropy.length % 4 !== 0
    ) {
      throw new Error("Invalid Entropy");
    }
    const entropyBits = bytesToBinary(Array.from(entropy));
    const checksumBits = deriveChecksumBits(entropy);
    const bits = entropyBits + checksumBits;
    const chunks = bits.match(/(.{1,11})/g);
    const words = chunks.map((binary) => {
      const index = binaryToByte(binary);
      return wordlist[index];
    });
    return words.join(" ");
  },
  generateMnemonic: function (strength = 128) {
    if (strength % 32 !== 0) {
      throw new Error("Invalid Strength");
    }
    return this.entropyToMnemonic(randomBytes(strength / 8));
  },
  mnemonicToSeed: function (mnemonic) {
    const mnemonicBuffer = Buffer.from(normalize(mnemonic), "utf8");
    const saltBuffer = Buffer.from(salt(normalize()), "utf8");
    return pbkdf2Function(mnemonicBuffer, saltBuffer, 2048, 64, "sha512");
  },
};

function pbkdf2Function(password, saltMixin, iterations, keylen, digest) {
  return pbkdf2.pbkdf2Sync(password, saltMixin, iterations, keylen, digest);
}
function normalize(str) {
  return (str || "").normalize("NFKD"); //NFKD: Compatibility Decomposition
}
function lpad(str, padString, length) {
  while (str.length < length) {
    str = padString + str;
  }
  return str;
}
function binaryToByte(bin) {
  return parseInt(bin, 2);
}
function bytesToBinary(bytes) {
  return bytes.map((x) => lpad(x.toString(2), "0", 8)).join("");
}
function deriveChecksumBits(entropyBuffer) {
  const ENT = entropyBuffer.length * 8;
  const CS = ENT / 32;
  const hash = createHash("sha256").update(entropyBuffer).digest();
  return bytesToBinary(Array.from(hash)).slice(0, CS);
}
function salt() {
  return "mnemonic";
}

module.exports = {
  bip39: Object.create(BIP39),
};
