const createHmac = require("create-hmac");
function hmacSHA512(key, data) {
  return createHmac("sha512", key).update(data).digest();
}

console.log(hmacSHA512(Buffer.from('Bitcoin seed', 'utf8'), '123344343423424234324'))