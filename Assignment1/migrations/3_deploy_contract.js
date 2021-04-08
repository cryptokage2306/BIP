const CarSeller = artifacts.require("CarSeller");

module.exports = function (deployer) {
  deployer.deploy(CarSeller);
};
