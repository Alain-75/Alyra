const demurr_address = "0xce885a438e5e5bbbe7e45de45f3a96c5a6a20fdd";
const demurr_abi = [
	{
		"constant": true,
		"inputs": [],
		"name": "_start_time",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "_members",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "heartbeat",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "REMINT_PERCENT",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_coin_mass",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "starting_coins",
		"outputs": [
			{
				"name": "coins",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "_accounts",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "recipient",
				"type": "address"
			},
			{
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "join",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_max_starting_coins",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "_sponsors",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "REMINT_PERIOD",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "max_starting_coins",
				"type": "uint256"
			},
			{
				"name": "coin_mass",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"payable": true,
		"stateMutability": "payable",
		"type": "fallback"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "_mass_before",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_mass_after",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_payback",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "_payback_success",
				"type": "bool"
			}
		],
		"name": "Remint",
		"type": "event"
	}
];

async function connect_to_metamask()
{
	const [address] = await ethereum.enable();

	const provider = new ethers.providers.Web3Provider(ethereum);

	const [block_number, balance, gas] = await Promise.all([
			provider.getBlockNumber()
		,	provider.getBalance(address)
		,	provider.getGasPrice()
		])

	console.log(block_number);
	console.log(balance.toString());
	console.log(gas.toString());
}

async function join()
{
	const [address] = await ethereum.enable();

	const provider = new ethers.providers.Web3Provider(ethereum);

	let demurr = new ethers.Contract(demurr_address, demurr_abi, provider.getSigner());

	let join_tx = await demurr.join();
	console.log(join_tx.hash);
	await join_tx.wait();
	console.log("Done");
}

async function get_start_coins()
{
	const [address] = await ethereum.enable();
	const provider = new ethers.providers.Web3Provider(ethereum);

	let demurr = new ethers.Contract(demurr_address, demurr_abi, provider);
	let coins = await demurr.starting_coins();
	console.log(coins.toString());
}

async function send_tokens()
{
	const [address] = await ethereum.enable();
	const provider = new ethers.providers.Web3Provider(ethereum);

	let amount = document.getElementById('amount_id').value;
	let recipient = document.getElementById('recipient_id').value;

	let demurr = new ethers.Contract(demurr_address, demurr_abi, provider.getSigner());
	let transfer_tx = await demurr.transfer(recipient, amount);
	console.log(transfer_tx.hash);
	await transfer_tx.wait();
	console.log("Done");
}


async function heartbeat()
{
	const [address] = await ethereum.enable();
	const provider = new ethers.providers.Web3Provider(ethereum);

	let amount = document.getElementById('amount_id').value;
	let recipient = document.getElementById('recipient_id').value;

	let demurr = new ethers.Contract(demurr_address, demurr_abi, provider.getSigner());

	demurr.on("Remint", (_mass_before, _mass_after, _payback, _payback_success, event) => {
		console.log("--------------");
		console.log(_mass_before.toString());
		console.log(_mass_after.toString());
		console.log(_payback.toString());
		console.log(_payback_success);
		console.log(event.blockNumber);
		console.log("--------------");
	});

	let heartbeat_tx = await demurr.heartbeat();
	console.log(heartbeat_tx.hash);
	await heartbeat_tx.wait();
	console.log("Done");
}
