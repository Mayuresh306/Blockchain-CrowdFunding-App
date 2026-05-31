const { ethers } = require("hardhat");

async function main() {
    const [user] = await ethers.getSigners();
    const ContractAddress = "0xe391a83C22c5C042fCF57a2C9Add1360Cc6ee47C";
    
    const Contract = await ethers.getContractAt("CrowdTank" , ContractAddress , user);

    const projectID = 2;

    const tx = await Contract.userWithdraw(projectID);
    await tx.wait;

    console.log(" User withdrew the funds from project :" , projectID);
}

main().catch((error) => {
    console.log(error);
    process.exitCode=1;
});