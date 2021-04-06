const { fromSeed } = require("./bip32");
const { bip39 } = require("./bip39");
const bitcoinLib = require("bitcoinjs-lib");
const bip32 = require("bip32");
const path = `m/44'/0'/0'/0/1`;
const mnemonic = bip39.generateMnemonic();
const seed = bip39.mnemonicToSeed(mnemonic);
const root = fromSeed(seed);
const child = root.derivePath(path);
const childObj = child.getBip32();
const { address } = bitcoinLib.payments.p2pkh({
  pubkey: child.getPubKey(),
});
console.log("privKey");
console.log(childObj.privKey.toString("hex"));
console.log("pubKey");
console.log(childObj.pubKey.toString("hex"));
console.log("chainCode");
console.log(childObj.chainCode.toString("hex"));
console.log("index");
console.log(childObj.index);
console.log("address");
console.log(address);
