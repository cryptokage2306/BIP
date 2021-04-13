const GoldERC20 = artifacts.require("GoldERC20");

module.exports = function (deployer) {
  deployer.deploy(GoldERC20, 100000);
};
