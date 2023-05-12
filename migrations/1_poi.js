const POI = artifacts.require("poi");
const DEP = artifacts.require("depositGovernance");
module.exports = async function (deployer) {
    await deployer.deploy(POI, 1, 3);
    const poiContract = await POI.deployed();
    const regAdd = await poiContract.currentRound();
    const depAdd = await poiContract.depositGovernanceContract();
    console.log(`registration contract address: ${regAdd}`);
    console.log(`depositGoverance contract address: ${depAdd}`);
    const depContract = await DEP.at(depAdd);
    await depContract.setRegistrationContract(regAdd);
};
