let ipfs_server = null;
let dapp = null;

const BASE58_BASIS = [
	ethers.utils.bigNumberify('0xc33ed2d1fbdd3bfe9c22b96164d38cf0d640e1c0ee8b61c39c5789a00000000000'),
	ethers.utils.bigNumberify('0x35dc5d77b83d07b8feef18a81bd06d803b1ab9dcf25b6a6aed55f100000000000'),
	ethers.utils.bigNumberify('0xedbafda67ca37188cf28263571f03b9716879e4acc9c514ab67280000000000'),
	ethers.utils.bigNumberify('0x4194afe74e855d1ce9b2ccbf4b91b829adf07249998c39bc55a40000000000'),
	ethers.utils.bigNumberify('0x12175ca9bd629545c4e1e034c565fdd68842547e3c035f6017a0000000000'),
	ethers.utils.bigNumberify('0x4fd9df9dbf7e28ed5357ba4a062c19c48e628f6af73b061210000000000'),
	ethers.utils.bigNumberify('0x160723345822cd7f432107408ef1aed51e73770306688eea8000000000'),
	ethers.utils.bigNumberify('0x6139fc7d1b1532bef353fcb3042abd0dc4329a88f025c64000000000'),
	ethers.utils.bigNumberify('0x1ad233ff339beab0431fff16e6aaafbd2d4bc0b304745a000000000'),
	ethers.utils.bigNumberify('0x7661fffc79dc527cbe58429a0bc53ca4176003162551000000000'),
	ethers.utils.bigNumberify('0x20a8469deca6b5a6d367cbc0907d07e6a5584778de2800000000'),
	ethers.utils.bigNumberify('0x90248722fa0bf5a28a9dfee80227dc40a4d518272400000000'),
	ethers.utils.bigNumberify('0x27c374ba3352bf58fa19ee0b096c1972efad8b13a00000000'),
	ethers.utils.bigNumberify('0xaf820335d9b3d9cf58b911d87035677fb7f528100000000'),
	ethers.utils.bigNumberify('0x306a7c78c94c18c670c04b8b27c81c8d29eb5a80000000'),
	ethers.utils.bigNumberify('0xd5b2b2a25e006d5a3847ec548c471ceaa75e40000000'),
	ethers.utils.bigNumberify('0x3af380ba0846bd100f8699786d516914981a0000000'),
	ethers.utils.bigNumberify('0x10432c56a12dff3091863bfde930f0d98b10000000'),
	ethers.utils.bigNumberify('0x47c76298d911a425d1c33dc1d04ac5f528000000'),
	ethers.utils.bigNumberify('0x13cd125f2165f8510dba46008014a08a4000000'),
	ethers.utils.bigNumberify('0x5765d5809369cc6e94dde5869f408fa000000'),
	ethers.utils.bigNumberify('0x181c17963a5226bd66dc1c01d3a7e1000000'),
	ethers.utils.bigNumberify('0x6a6a5673c39f9081c6007b9e21ca800000'),
	ethers.utils.bigNumberify('0x1d5b20ad2d2330b10a7bb82b9f6400000'),
	ethers.utils.bigNumberify('0x819237f3896f2f30bb832ce3da00000'),
	ethers.utils.bigNumberify('0x23be67b5f0f2889aaf505301100000'),
	ethers.utils.bigNumberify('0x9dc3feb91eaa1452788eac280000'),
	ethers.utils.bigNumberify('0x2b85840fc1d6a480ae7fa240000'),
	ethers.utils.bigNumberify('0xc018588c2b6cc46cf08ba0000'),
	ethers.utils.bigNumberify('0x34fde3761da26b26e1410000'),
	ethers.utils.bigNumberify('0xe9e506734501d8f23a8000'),
	ethers.utils.bigNumberify('0x4085ccd059a83bd8e4000'),
	ethers.utils.bigNumberify('0x11cca26e71024579a000'),
	ethers.utils.bigNumberify('0x4e900abb53e6b71000'),
	ethers.utils.bigNumberify('0x15ac264554f032800'),
	ethers.utils.bigNumberify('0x5fa8624c7fba400'),
	ethers.utils.bigNumberify('0x1a636a90b07a00'),
	ethers.utils.bigNumberify('0x7479027ea100'),
	ethers.utils.bigNumberify('0x202161caa80'),
	ethers.utils.bigNumberify('0x8dd122640'),
	ethers.utils.bigNumberify('0x271f35a0'),
	ethers.utils.bigNumberify('0xacad10'),
	ethers.utils.bigNumberify('0x2fa28'),
	ethers.utils.bigNumberify('0xd24'),
	ethers.utils.bigNumberify('0x3a'),
	ethers.utils.bigNumberify('0x1'),
]

const BASE58_DIGITS = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

function base58_to_bignumber(encoded)
{
	if(typeof encoded!=='string')
		throw '"decode" only accepts strings.';            
	var decoded = ethers.utils.bigNumberify(0);

	var i
	for (i = 0; i < encoded.length; ++i)
	{
		const pos = BASE58_DIGITS.indexOf(encoded[i]);
		if (pos < 0)
		{
			throw '"decode" can\'t find "' + encoded[0] + '" in the alphabet: "' + BASE58_DIGITS + '"';
		}

		decoded = decoded.add(BASE58_BASIS[i].mul(pos));
	}

	return decoded;
}

function bignumber_to_base58(number)
{
	var encoded = ""

	while (false == number.isZero())
	{
		var remainder = number.mod(58)
		encoded = BASE58_DIGITS[remainder] + encoded
		number = number.div(58)
	}

	return encoded
}

const MAJOKE_REGISTER_COST = 100;

const MAJOKE_ADDRESS = "0x037a2befd78503977f9d9b817bbf8cad56199a3d"; // ON KOVAN

const MAJOKE_ABI = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "name",
				"type": "string"
			},
			{
				"name": "hash",
				"type": "bytes32"
			}
		],
		"name": "register_card",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "card_registering_cost",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "_card_hashes",
		"outputs": [
			{
				"name": "",
				"type": "bytes32"
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
				"type": "bytes32"
			}
		],
		"name": "_card_names",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "_card_registering_cost",
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
				"name": "name",
				"type": "string"
			}
		],
		"name": "card_from_name",
		"outputs": [
			{
				"name": "card_hash",
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
		"name": "nb_cards",
		"outputs": [
			{
				"name": "nb",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	}
];

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
			const contract = new ethers.Contract(MAJOKE_ADDRESS, MAJOKE_ABI, provider.getSigner())
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

function ipfs_init()
{
	display_message("IPFS Starting&hellip;")
	ipfs_server = new window.Ipfs()

	ipfs_server.on('ready', () => {
		display_message('IPFS ready!')
	})
}

async function register_card()
{
	if (false == dapp_is_on())
	{
		await establish_dapp_connection();
	}

	const card_name = document.getElementById("register.card_name").value
	const image = document.getElementById("register.card_image").files[0]

	var reader = new FileReader()

	display_message("Reading image")

	// Closure to capture the file information.
	reader.onload = ((image_file) =>
		{
			display_message("Pushing image to IPFS")

			ipfs_server.add( ipfs_server.types.Buffer.from(reader.result) ).then( async (results) =>
				{
					const hash = results[0].hash
					display_message("Image added to IPFS with hash: " + hash)

					const bytes = base58_to_bignumber(hash)

					var hex_string = bytes.toHexString()

					if ( hex_string.substr(2,2) != "12" || hex_string.substr(4,2) != "20" )
					{
						display_error("Unexpected IPFS hash: " + hex_string)
						return 
					}

					hex_string = hex_string.substr(6)

					let overrides = {
						value: MAJOKE_REGISTER_COST,
					};

					display_message("Creating transaction with name " + card_name + " and hash value: " + hex_string.length + " " + hex_string)
					const tx  = await dapp.contract.register_card(card_name, "0x" + hex_string, overrides)
					display_message("Transaction created")

					try
					{
						tx.wait().then(() =>
							{
								display_message("Image hash saved on blockchain: " + hash)
							}
						)
					}
					catch(err)
					{
						display_error(err)
					}
				}
			)
		}
	);

	reader.readAsBinaryString(image);
}

function ipfs_hash_from_bytes32(bytes32_hash)
{
	return bignumber_to_base58(ethers.utils.bigNumberify("0x1220" + bytes32_hash.substr(2)))
}

async function card_hash_from_name(card_name)
{
	const bytes32_hash  = await dapp.contract.card_from_name(card_name)

	if (bytes32_hash == "0x0000000000000000000000000000000000000000000000000000000000000000")
	{
		throw "Unknown card with name: " + card_name
	}

	const hash = ipfs_hash_from_bytes32(bytes32_hash)
	display_message("Card '" + card_name + "' has hex hash: " + bytes32_hash + " and b58 hash: " + hash)
	return hash
}

function display_card_from_hash(card_hash, elem_id)
{
	ipfs_server.cat( card_hash ).then( (results) =>
		{
			display_message("Card found: " + card_hash)
			document.getElementById(elem_id).src = "data:image/blob;base64," + window.btoa(results)
		}
	)
}

async function display_card()
{
	const card_name = document.getElementById("display.card_name").value
	var card_hash = document.getElementById("display.card_hash").value

	if (card_name && card_hash)
	{
		display_error("PLEASE ENTER EITHER NAME _OR_ HASH")
		return
	}

	if (false == dapp_is_on())
	{
		await establish_dapp_connection();
	}

	if (card_name)
	{
		card_hash = await card_hash_from_name(card_name, "display.result")
	}

	display_card_from_hash(card_hash, "display.result")
}

function last_cards_displayer(pos)
{
	return (bytes32_hash) =>
	{
		const hash = ipfs_hash_from_bytes32(bytes32_hash)
		display_message("Displaying in " + pos + " from b32 hash: " + bytes32_hash + " b58 hash: " + hash)
		display_card_from_hash(hash, "last.result_" + pos + "_image")
		dapp.contract._card_names(bytes32_hash).then( (name) =>
			{
				document.getElementById("last.result_" + pos + "_name").innerHTML = name
			}
		)
	}
}

async function last_cards()
{
	var i
	for( i = 0; i < 10; ++i )
	{
		document.getElementById("last.result_" + i + "_image").src = ""
	}

	if (false == dapp_is_on())
	{
		await establish_dapp_connection();
	}

	var nb_cards = document.getElementById("last.number").value

	const total_cards  = (await dapp.contract.nb_cards()).toNumber()
	nb_cards = Math.min(nb_cards, total_cards)

	console.log("showing last ", nb_cards)

	for( i = 0; i < nb_cards; ++i )
	{
		dapp.contract._card_hashes(total_cards - 1 - i).then(last_cards_displayer(i))
	}
}
