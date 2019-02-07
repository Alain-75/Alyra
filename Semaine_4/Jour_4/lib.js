let dapp = null;

const credibilite_abi = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "dev",
				"type": "bytes32"
			}
		],
		"name": "remettre",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
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
		"name": "cred",
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
				"name": "dd",
				"type": "string"
			}
		],
		"name": "produireHash",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "destinataire",
				"type": "address"
			},
			{
				"name": "valeur",
				"type": "uint256"
			}
		],
		"name": "transfer",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

const credibilite_address = "0x451875bdd0e524882550ec1ce52bcc4d0ff90eae";

let network_name = null;

function dapp_is_on()
{
	return dapp !== null;
}

async function establish_dapp_connection()
{
	try
	{
		const [address] = await ethereum.enable();
		const provider = new ethers.providers.Web3Provider(ethereum);
		const contract = new ethers.Contract(credibilite_address, credibilite_abi, provider.getSigner());
		dapp = { address, provider, contract };
		console.log("Dapp is connected.");
	}
	catch(err)
	{
		dapp = {};
		console.error(err);
	}
}

async function get_homework_hash()
{
	const hw_url = document.getElementById('homework_url').value;

	dapp.contract.produireHash(hw_url).then((hash) =>
		{
			document.getElementById('hash').innerHTML = hash;
			document.getElementById('submit_homework').disabled = false;
		}
	);
}

async function submit_homework()
{
	const hw_hash = document.getElementById('hash').innerHTML;

	dapp.contract.remettre(hw_hash).then((remettre_tx) =>
		{
			remettre_tx.wait().then((cred) =>
				{
					let tx_result = cred.transactionHash;

					if (network_name != null)
					{
						tx_result = "<a href='https://"
							+ network_name
							+ ".etherscan.io/tx/"
							+ tx_result
							+ "' alt='Check transaction on etherscan'>"
							+ tx_result
							+ "</a>";
					}

					document.getElementById('tx').innerHTML = tx_result;
				}
			);
		}
	);
}

async function update_page_content()
{
	const address = dapp.address;
	const provider = dapp.provider;

	document.getElementById('account').innerHTML = "Account @" + address;
	document.getElementById('contract').innerHTML = "Contract @" + credibilite_address;

	provider.getNetwork().then((network) =>
		{
			network_name = network.name;
			document.getElementById('network').innerHTML = network.name;
		}
	);

	provider.getBlockNumber().then((block_number) =>
		{
			document.getElementById('block_number').innerHTML = block_number;
		}
	);

	provider.getGasPrice().then((gas_price) =>
		{
			document.getElementById('gas_price').innerHTML = gas_price.toString();
		}
	);

	provider.getBalance(address).then((balance) =>
		{
			document.getElementById('balance').innerHTML = balance;
		}
	);

	provider.getTransactionCount(address).then((nb_tx) =>
		{
			document.getElementById('nb_tx').innerHTML = nb_tx.toString();
		}
	);

	dapp.contract.cred(address).then((cred) =>
		{
			document.getElementById('credibility').innerHTML = cred.toString();
		}
	);
}