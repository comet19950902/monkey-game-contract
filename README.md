# MonkeyGame

### first: ERC20
	$ yarn hardhat compile

	$ yarn hardhat run ./scripts/deploy_erc20.ts --network setpol
	
	$ yarn hardhat verify 0x0f81d97d3ae1f0EAc85111818E2C56d4A6234109 1000 --network setpol

### Second: Game
	$ yarn hardhat compile

	$ yarn hardhat run ./scripts/deploy_game.ts --network setpol
	
	$ yarn hardhat verify 0x843c322BC9Fc73Cb265a932870C90FE667D5e32a 0x0f81d97d3ae1f0EAc85111818E2C56d4A6234109 0x9406aCF779A630a1451De816a957DA9322478A48 --network setpol
	
Test:
	https://sepolia.etherscan.io/0x...

### Game Logic
	Approve:
		Owner => Contract
		Contract => devWallet
		Contract => Owner
	Transaction:
		Owner => Contract


### Example
	Approve
		Contract:
			0x843c322BC9Fc73Cb265a932870C90FE667D5e32a
		Owner: 
			0xbCeD2ba12c7C2851Cb93C27b4f50399333fE35F4
		devWallet:
			0x9406aCF779A630a1451De816a957DA9322478A48

		Owner => Contract
			0xbCeD2ba12c7C2851Cb93C27b4f50399333fE35F4 => 0x843c322BC9Fc73Cb265a932870C90FE667D5e32a
		Contract => Owner
			0x843c322BC9Fc73Cb265a932870C90FE667D5e32a => 0xbCeD2ba12c7C2851Cb93C27b4f50399333fE35F4
		Contract => devWallet
			0x843c322BC9Fc73Cb265a932870C90FE667D5e32a => 0x9406aCF779A630a1451De816a957DA9322478A48
	Transfer
		Owner => Contract
			0xbCeD2ba12c7C2851Cb93C27b4f50399333fE35F4 => 0x843c322BC9Fc73Cb265a932870C90FE667D5e32a