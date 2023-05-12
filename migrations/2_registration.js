const registration = artifacts.require("registration");
module.exports = function (deployer) {
    deployer.deploy(
        registration,
        1,
        1000,
        1000,
        3,
        "0xeDF16827c53A4DF160E26ff3Ed208a8827E86d3e"
    );
};
