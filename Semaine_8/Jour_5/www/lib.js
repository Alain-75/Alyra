let dapp = null;

const PAYBUDDY_ABI = [];

const PAYBUDDY_ADDRESS = "";

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
	return dapp !== null;
}

async function establish_dapp_connection()
{
	try
	{
		let [address] = await ethereum.enable();
		const provider = new ethers.providers.Web3Provider(ethereum);
		const contract = new ethers.Contract(DIVERGENT_ADDRESS, DIVERGENT_ABI, provider.getSigner());
		address = address.toLowerCase();
		dapp = { address, provider, contract };
		log_message("Connected to ethereum");
	}
	catch( err )
	{
		dapp = {};
		log_error(err);
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
			}
		})
	}
}

