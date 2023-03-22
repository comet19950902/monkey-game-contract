# MonkeyGame

### first: ERC20
	$ yarn hardhat compile

	$ yarn hardhat run ./scripts/deploy_erc20.ts --network setpol
	
	$ yarn hardhat verify 0x36bC3a54E108193c23C3f2023a9DbCDc59b76dc7 10000 --network setpol

### Second: Game
	$ yarn hardhat compile

	$ yarn hardhat run ./scripts/deploy_game.ts --network setpol
	
	$ yarn hardhat verify 0x7F556F155F6139AEA26db06D0213087d5f389BF7 0x36bC3a54E108193c23C3f2023a9DbCDc59b76dc7 0x9406aCF779A630a1451De816a957DA9322478A48 --network setpol
	
Test:
	https://sepolia.etherscan.io/0x...