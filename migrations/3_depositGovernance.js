const depositGovernance = artifacts.require("depositGovernance");
module.exports = function (deployer) {
    deployer.deploy(depositGovernance);
};
