let ipfs_server = null;

function ipfs_init()
{
	document.getElementById("status").innerHTML = "Starting&hellip;"
	ipfs_server = new window.Ipfs()

	ipfs_server.on('ready', () => {
		document.getElementById("status").innerHTML = "Ready"
	})
}

function refresh_list()
{
	ipfs_server.swarm.addrs().then( (addresses) =>
		{
			let list = ""

			for (var i = 0; i < addresses.length && i <= 10; i++)
			{
				list += "<li>" + addresses[i].id._idB58String +
					"<button onclick='ping_server(\"" + addresses[i].id._idB58String + "\")'>Ping</button>" +
					"<span id='ping_" + addresses[i].id._idB58String + "'></span></li>"
			}

			document.getElementById("peer_list").innerHTML = list
		}
	)
}

function add_text()
{
	const value = document.getElementById("add_text").value
	console.log("Adding:", value)

	ipfs_server.add( ipfs_server.types.Buffer.from(value) ).then( (results) =>
		{
			document.getElementById("add_text_result").innerHTML = results[0].hash
			console.log("Added!")
		}
	)
}

function get_text()
{
	const hash = document.getElementById("get_text").value
	console.log("Searching:", hash)

	ipfs_server.cat( hash ).then( (results) =>
		{
			document.getElementById("get_text_result").innerHTML = results
			console.log("Found!")
		}
	)
}

function add_image()
{
	const image = document.getElementById("add_image").files[0]
	var reader = new FileReader()

	reader.onload = ((image_file) =>
		{
			ipfs_server.add( ipfs_server.types.Buffer.from(reader.result) ).then( (results) =>
				{
					document.getElementById("add_image_result").innerHTML = results[0].hash
					console.log("Added!")
				}
			)
		}
	);

	reader.readAsBinaryString(image);
}

function get_image()
{
	const hash = document.getElementById("get_image").value
	console.log("Searching:", hash)

	ipfs_server.cat( hash ).then( (results) =>
		{
			console.log("Found!")
			// var b64 = window.btoa(results)
			// console.log(b64)
			document.getElementById("get_image_result").src = "data:image/blob;base64," + window.btoa(results)
		}
	)
}

function ping_server(address)
{
	console.log("Pinging:", address)
	ipfs_server.ping(address).then( (result) =>
		{
			document.getElementById("ping_" + address).innerHTML = result[1].time	
		}
	)
}
