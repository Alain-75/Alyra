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

async function update_page_content()
{
	const address = dapp.address;
	const provider = dapp.provider;

	document.getElementById('account').innerHTML = address;

	provider.getNetwork().then((network) =>
		{
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

}