let ipfs_server = null;
let dapp = null;

const PINFINITY_NODE_ADDRESS = ""

const PINFINITY_CONTRACT_ADDRESS = "0x0"

const PINFINITY_CONTRACT_ABI = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "ipfs_file_id",
				"type": "string"
			}
		],
		"name": "pay_storage",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_pin_cost",
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
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "origin",
				"type": "address"
			},
			{
				"indexed": true,
				"name": "ipfs_file_id",
				"type": "string"
			}
		],
		"name": "Pin",
		"type": "event"
	}
]



function display_error(err)
{
	console.log(err)
	document.getElementById("message_header").innerHTML += "<p class='error'>Error: " + err + "</p>"
}

function display_message(message)
{
	console.log(message)
	document.getElementById("message_header").innerHTML += "<p class='message'>" + message + "</p>"
}

function dapp_is_on()
{
	return dapp !== null;
}

async function establish_dapp_connection()
{
	if (false == dapp_is_on())
	{
		try
		{
			let [address] = await ethereum.enable()
			const provider = new ethers.providers.Web3Provider(ethereum)
			const contract = new ethers.Contract(PINFINITY_CONTRACT_ADDRESS, PINFINITY_CONTRACT_ABI, provider.getSigner())
			address = address.toLowerCase()
			dapp = { address, provider, contract }
			display_message("Dapp is connected!")
		}
		catch(err)
		{
			dapp = {}
			display_error(err)
		}
	}
}

async function pay_storage(hash)
{
	try
	{
		dapp.contract.pay_storage(hash, overrides).then( (tx) =>
			{
				display_message("Ethereum transaction created")
				tx.wait().then( () => {display_message("Ethereum transaction done")} )
			}
		)
	}
	catch(err)
	{
		console.log(err)
		display_message("Issue with Ethereum network")
	}
}

async function pin()
{
	const hash = document.getElementById("file_hash").value
	const file = document.getElementById("file_contents").files[0]

	if (hash && file)
	{
		display_error("Enter EITHER a hash OR a file")
	}

	if (false == dapp_is_on())
	{
		await establish_dapp_connection()
	}

	const pin_cost = await dapp.contract._pin_cost()

	let overrides = {
		value: pin_cost,
	};

	if (hash)
	{
		pay_storage(hash)
	}
	else
	{
		display_message("Starting in-browser IPFS node&hellip;")

		try
		{
			ipfs_server = new window.Ipfs()

			ipfs_server.on('ready', () => {
				display_message('In-browser IPFS ready!')

				await ipfs.swarm.connect(PINFINITY_NODE_ADDRESS)

				var reader = new FileReader()
				display_message("Reading file")

				reader.onload = ((file) => {
					display_message("Pushing file to IPFS")

					ipfs_server.add( ipfs_server.types.Buffer.from(reader.result) ).then( async (results) =>
						{
							const hash = results[0].hash
							display_message("File pushed into local IPFS with hash: " + hash)
							pay_storage(hash)
						}
					)
				})

				reader.readAsBinaryString(file);
			})
		}
		catch(err)
		{
			console.log(err)
			display_message("IPFS error")
		}
	}
}
