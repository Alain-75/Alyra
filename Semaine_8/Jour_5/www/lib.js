let dapp = null

let selected_channel = null

const PAYBUDDY_CHANNEL_ABI = [
	{
		"constant": true,
		"inputs": [],
		"name": "_initiator",
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
		"constant": true,
		"inputs": [],
		"name": "_last_nonce",
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
		"inputs": [],
		"name": "liquidate",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_closing_block",
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
		"name": "_counterpart",
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
		"name": "stop_wait",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "nonce",
				"type": "uint256"
			},
			{
				"name": "initiator_balance",
				"type": "uint256"
			},
			{
				"name": "counterpart_balance",
				"type": "uint256"
			},
			{
				"name": "opposite_signature",
				"type": "bytes"
			}
		],
		"name": "submit_balance",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "counterpart_join",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "initiator_fund",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_amount",
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
				"name": "nonce",
				"type": "uint256"
			},
			{
				"name": "initiator_balance",
				"type": "uint256"
			},
			{
				"name": "counterpart_balance",
				"type": "uint256"
			}
		],
		"name": "message",
		"outputs": [
			{
				"name": "mess",
				"type": "bytes32"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_state",
		"outputs": [
			{
				"name": "",
				"type": "uint8"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_initiator_balance",
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
		"inputs": [],
		"name": "counterpart_fund",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "recover",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "cancel",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_counterpart_balance",
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
				"name": "initiator",
				"type": "address"
			},
			{
				"name": "counterpart",
				"type": "address"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "initiator_balance",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "counterpart_balance",
				"type": "uint256"
			}
		],
		"name": "Active",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "last_nonce",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "initiator_balance",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "counterpart_balance",
				"type": "uint256"
			}
		],
		"name": "Closing",
		"type": "event"
	}
]

const PAYBUDDY_CHANNELS_ABI = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "counterpart",
				"type": "address"
			}
		],
		"name": "add_channel",
		"outputs": [
			{
				"name": "channel",
				"type": "address"
			}
		],
		"payable": true,
		"stateMutability": "payable",
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
		"name": "_channels",
		"outputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
]

const PAYBUDDY_CHANNELS_ADDRESS = "0x5a2fd00fa6d978c3ffc3a5ffe649d94a9251e8d9"

function log_message( message )
{
	document.getElementById("messages").innerHTML = "<div class='message'>" + message + "</div>"
	console.log(message)
}

function log_error( err )
{
	document.getElementById("messages").innerHTML = "<div class='error'>" + err + "</div>"
	console.error(err)
}

function show( name )
{
	document.getElementById(name).style.display = 'inline'
}

function hide( name )
{
	document.getElementById(name).style.display = 'none'
}

function dapp_is_on()
{
	return dapp !== null
}

async function establish_dapp_connection()
{
	try
	{
		let [address] = await ethereum.enable()
		const provider = new ethers.providers.Web3Provider(ethereum)
		const channels = new ethers.Contract(PAYBUDDY_CHANNELS_ADDRESS, PAYBUDDY_CHANNELS_ABI, provider.getSigner())
		address = address.toLowerCase()
		dapp = { address, provider, channels }
		log_message("Connected to ethereum")
	}
	catch( err )
	{
		dapp = {}
		log_error(err)
	}
}

function eth_connect()
{
	if ( false == dapp_is_on() )
	{
		establish_dapp_connection().then( () => {
			if ( dapp_is_on() )
			{
				hide("connect_eth_form")
				show("eth_connected")
				hide("eth_connection")
				list_channels()
				show("channel_connection")
			}
		})
	}
}

function is_channel_connected()
{
	return selected_channel != null;
}

async function list_channels()
{
	document.getElementById('channel_list').innerHTML = ''
	i = 0

	while(true)
	{
		let channel_address = null

		try
		{
			channel_address = await dapp.channels._channels( i )
		}
		catch( err )
		{
			break
		}

		const channel = new ethers.Contract(channel_address, PAYBUDDY_CHANNEL_ABI, dapp.provider)
		const initiator = await channel._initiator()
		const counterpart = await channel._counterpart()

		let recipient = null

		if ( initiator.toLowerCase() == dapp.address )
		{
			recipient = counterpart
		}
		else if ( counterpart.toLowerCase() == dapp.address )
		{
			recipient = initiator
		}

		if ( recipient !=  null )
		{
			const state = await channel._state()
			const amount = ethers.utils.formatUnits(await channel._amount(), 'finney')

			let contents = '<p class="state_' + state + '">Amount: ' + amount + ' finney, Recipient: ' + recipient

			if ( state == 0 && recipient == initiator )
			{
				contents +=	'<button onclick="accept_channel(\'' + channel_address
					+ '\')">Accept</button></p>'
			}
			else if ( state == 0 && recipient == counterpart )
			{
				contents +=	'<button onclick="cancel_channel(\'' + channel_address
					+ '\')">Cancel</button></p>'
			}
			else 
			{
				contents +=	'<button onclick="connect_channel(\'' + channel_address
					+ '\')">Connect</button></p>'
			}

			document.getElementById('channel_list').innerHTML = contents
		}

		i++
	}
}

async function accept_channel(address)
{
	selected_channel = new ethers.Contract(address, PAYBUDDY_CHANNEL_ABI, dapp.provider.getSigner())

	const initiator = await selected_channel._initiator()
	const counterpart = await selected_channel._counterpart()
	const state = await selected_channel._state()

	let recipient = null
	let balance = 0

	if ( initiator.toLowerCase() == dapp.address )
	{
		balance = await selected_channel._initiator_balance()
		recipient = counterpart
	}
	else if ( counterpart.toLowerCase() == dapp.address )
	{
		balance = await selected_channel._counterpart_balance()
		recipient = initiator
	}
	else
	{
		log_error("Unexpected channel")
		return
	}

	document.getElementById('info').className = "state_" + state
	document.getElementById('info.balance').innerHTML = ethers.utils.formatUnits(balance, 'finney') + ' finney'
	document.getElementById('info.recipient').innerHTML = recipient

	if ( state == 0 && recipient == initiator )
	{
		const amount = await selected_channel._amount()

		let overrides = {
			value: amount,
		};

		selected_channel.counterpart_join( overrides ).then( (tx) => {
			tx.wait().then( async (results) => {
				log_message("Channel joined")
				const state = await selected_channel._state()
				document.getElementById('info').className = "state_" + state
				hide("channel_connection")
				show("send_eth")
				show("receive_eth")
			})
		})
	}
}

async function connect_channel(address)
{
	selected_channel = new ethers.Contract(address, PAYBUDDY_CHANNEL_ABI, dapp.provider.getSigner())

	const initiator = await selected_channel._initiator()
	const counterpart = await selected_channel._counterpart()
	const state = await selected_channel._state()

	let recipient = null
	let balance = 0

	if ( initiator.toLowerCase() == dapp.address )
	{
		balance = await selected_channel._initiator_balance()
		recipient = counterpart
	}
	else if ( counterpart.toLowerCase() == dapp.address )
	{
		balance = await selected_channel._counterpart_balance()
		recipient = initiator
	}
	else
	{
		log_error("Unexpected channel")
		return
	}

	document.getElementById('info').className = "state_" + state
	document.getElementById('info.balance').innerHTML = ethers.utils.formatUnits(balance, 'finney') + ' finney'
	document.getElementById('info.recipient').innerHTML = recipient
	hide("channel_connection")
	show("send_eth")
	show("receive_eth")
}

function channel_create()
{
	hide("channel_created")

	const channel_amount = ethers.utils.parseUnits(document.getElementById('channel_amount').value, 'finney')
	const counterpart_address = document.getElementById('counterpart_address').value

	let overrides = {
		value: channel_amount,
	};

	dapp.channels.add_channel( counterpart_address, overrides ).then( (tx) => {
		tx.wait().then( (results) => {
			list_channels()
			show('channel_created')
		})
	})
}

function init()
{
	if ( dapp_is_on() )
	{
		hide("eth_connection")

		if ( is_channel_connected() )
		{
			hide("channel_connection")
			show("send_eth")
			show("receive_eth")
		}
		else
		{
			list_channels()
			hide("channel_created")
			hide("send_eth")
			hide("receive_eth")
		}
	}
	else
	{
		hide("eth_connected")
		hide("channel_created")
		hide("channel_connection")
		hide("send_eth")
		hide("receive_eth")
	}

	hide("loading")
	show("forms")
}