const { ethers } = require("hardhat");

async function main() {
    const [user] = await ethers.getSigners();
    const ContractAddress = "0xd3F92405B5effa79C00e89f235E7679b2D98e598";
    
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