const CarStore = artifacts.require("CarStore");

module.exports = function (deployer) {
  deployer.deploy(CarStore);
};
