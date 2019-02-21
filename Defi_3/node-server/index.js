const ethers = require('ethers')
const Ipfs= require('ipfs')

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


const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545")
const node = new Ipfs()

node.on('ready', () => {
 console.log("IPFS prêt")
 provider.getNetwork().then(
   r =>  console.log("Ethereum connecté sur ", r)
 )
})
