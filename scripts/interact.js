const { ethers } = require("hardhat");

async function main() {
    console.log('Getting the non fun token contract...\n');
    const contractAddress = '0x5fbdb2315678afecb367f032d93f642f64180aa3';
    const lockContract = await ethers.getContractAt('Lock', contractAddress);

    const signers = await ethers.getSigners();
    const provider = ethers.provider;

    console.log(signers[0]);

    const balance = await provider.getBalance("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
    console.log("BALANCE ISSSSSSSSSSSSs: " + balance);


    //await lockContract.lock(1, 1665072603);
    //console.log("Locked 100wei, for 60 seconds.")
    await lockContract.withdraw(1);
    
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    });