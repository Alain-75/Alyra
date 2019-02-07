let dapp = null;

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
		dapp = { address, provider };
		console.log("Dapp is connected.");
	}
	catch(err)
	{
		dapp = {};
		console.error(err);
	}
}

let network = null;
let block_number = 0;
let gas_price = 0;
let balance = 0;
let nb_tx = 0;

async function get_chain_info()
{
	const address = dapp.address;
	const provider = dapp.provider;

	[block_number, network, gas_price, balance, nb_tx] = await Promise.all([
			provider.getBlockNumber(),
			provider.getNetwork(),
			provider.getGasPrice(),
			provider.getBalance(address),
			provider.getTransactionCount(address),
		]);
}

function update_info_view()
{
	if (network !== null)
	{
		document.getElementById('network').innerHTML = network.name;
		document.getElementById('block_number').innerHTML = block_number;
		document.getElementById('gas_price').innerHTML = gas_price.toString();
		document.getElementById('account').innerHTML = dapp.address;
		document.getElementById('balance').innerHTML = balance;
		document.getElementById('nb_tx').innerHTML = nb_tx.toString();
	}
}