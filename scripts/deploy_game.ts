import { ethers } from "hardhat";

async function main() {
  const tokenAddress = "0x0f81d97d3ae1f0EAc85111818E2C56d4A6234109";       // ERC20_Contract address
  const devWallet = "0x9406aCF779A630a1451De816a957DA9322478A48";          // My Wallet address

  const MonkeyGame = await ethers.getContractFactory("MonkeyGame");
  const monkeyGame = await MonkeyGame.deploy(
    tokenAddress,
    devWallet
  );

  await monkeyGame.deployed();

  console.log(`MonkeyGame Contract is deployed to: ${monkeyGame.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
