let dapp = null;

const JobStatus = Object.freeze({"WAITING":0, "ONGOING":1, "FINISHED":2});

const SECONDS_IN_ONE_HOUR = 60*60;

const DIVERGENT_ABI = [
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "_artists",
		"outputs": [
			{
				"name": "_name",
				"type": "string"
			},
			{
				"name": "_reputation",
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
				"name": "title",
				"type": "string"
			},
			{
				"name": "description",
				"type": "string"
			},
			{
				"name": "required_reputation",
				"type": "uint256"
			},
			{
				"name": "delay_seconds",
				"type": "uint256"
			}
		],
		"name": "submit_job",
		"outputs": [],
		"payable": true,
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			},
			{
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "job_candidate",
		"outputs": [
			{
				"components": [
					{
						"name": "_address",
						"type": "address"
					},
					{
						"name": "_name",
						"type": "string"
					},
					{
						"name": "_reputation",
						"type": "uint256"
					}
				],
				"name": "candidate",
				"type": "tuple"
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
				"name": "job_hash",
				"type": "bytes32"
			},
			{
				"name": "apply_blame",
				"type": "bool"
			}
		],
		"name": "close_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "name",
				"type": "string"
			}
		],
		"name": "register_client",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "MINIMUM_JOB_PAY",
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
				"name": "job_hash",
				"type": "bytes32"
			},
			{
				"name": "delivery_url",
				"type": "string"
			}
		],
		"name": "deliver_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "cancel_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "name",
				"type": "string"
			}
		],
		"name": "register_artist",
		"outputs": [],
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
		"name": "_clients",
		"outputs": [
			{
				"name": "_name",
				"type": "string"
			},
			{
				"name": "_reputation",
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
				"name": "job_hash",
				"type": "bytes32"
			},
			{
				"name": "artist",
				"type": "address"
			}
		],
		"name": "hire",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "nb_candidates",
		"outputs": [
			{
				"name": "nb",
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
				"name": "job_hash",
				"type": "bytes32"
			},
			{
				"name": "apply_blame",
				"type": "bool"
			}
		],
		"name": "renew_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
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
		"name": "_jobs",
		"outputs": [
			{
				"name": "_issuer",
				"type": "address"
			},
			{
				"name": "_title",
				"type": "string"
			},
			{
				"name": "_description",
				"type": "string"
			},
			{
				"name": "_pay",
				"type": "uint256"
			},
			{
				"name": "_required_reputation",
				"type": "uint256"
			},
			{
				"name": "_hash",
				"type": "bytes32"
			},
			{
				"name": "_taker",
				"type": "address"
			},
			{
				"name": "_delay_seconds",
				"type": "uint256"
			},
			{
				"name": "_take_time",
				"type": "uint256"
			},
			{
				"name": "_delivery_time",
				"type": "uint256"
			},
			{
				"name": "_delivery_url_hash",
				"type": "bytes32"
			},
			{
				"name": "_status",
				"type": "uint8"
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
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "give_up_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "find_job",
		"outputs": [
			{
				"components": [
					{
						"name": "_issuer",
						"type": "address"
					},
					{
						"name": "_title",
						"type": "string"
					},
					{
						"name": "_description",
						"type": "string"
					},
					{
						"name": "_pay",
						"type": "uint256"
					},
					{
						"name": "_required_reputation",
						"type": "uint256"
					},
					{
						"name": "_hash",
						"type": "bytes32"
					},
					{
						"name": "_candidates",
						"type": "address[]"
					},
					{
						"name": "_taker",
						"type": "address"
					},
					{
						"name": "_delay_seconds",
						"type": "uint256"
					},
					{
						"name": "_take_time",
						"type": "uint256"
					},
					{
						"name": "_delivery_time",
						"type": "uint256"
					},
					{
						"name": "_delivery_url_hash",
						"type": "bytes32"
					},
					{
						"name": "_status",
						"type": "uint8"
					}
				],
				"name": "",
				"type": "tuple"
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
				"name": "someone",
				"type": "address"
			}
		],
		"name": "blacklist",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "candidate_for_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
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
				"name": "title",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "issuer",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "JobSubmitted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "candidate",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "JobCandidated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "hire",
				"type": "address"
			},
			{
				"indexed": false,
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "JobHire",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "JobResigned",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "delivery_url",
				"type": "string"
			},
			{
				"indexed": false,
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "JobFinished",
		"type": "event"
	}
];

const DIVERGENT_ADDRESS = "0xe0969ad461b6a0cad544da7eb62290498cc09491";

function remove_element_by_id(id)
{
	let element = document.getElementById(id);
	element.parentNode.removeChild(element);
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
			let [address] = await ethereum.enable();
			const provider = new ethers.providers.Web3Provider(ethereum);
			const contract = new ethers.Contract(DIVERGENT_ADDRESS, DIVERGENT_ABI, provider.getSigner());
			address = address.toLowerCase();
			dapp = { address, provider, contract };
			console.log("Dapp is connected.");
		}
		catch(err)
		{
			dapp = {};
			console.error(err);
		}
	}
}

function ethers_to_string(number)
{
	return number.toString() + "&nbsp;wei";
}

function job_to_xhtml(job)
{
	return "<h3 class='job_title'>" + job._title
		+ "</h3><p class='job_pay'>Pay: " + ethers_to_string(job._pay)
		+ "</p><p class='job_reputation'>Reputation: " + job._required_reputation.toString()
		+ "</p><p class='delay'>Delay: " + (job._delay_seconds.div(SECONDS_IN_ONE_HOUR).toString())
		+ " hours</p><p class='job_desciption'>" + job._description
		+ "</p>";
}

function candidate_markups(name, reputation, address, job_hash)
{
	return "<p>" + name + " (" + reputation + ")"
		+ "<button onclick='hire(\"" + job_hash + "\", \"" + address + "\")'>Hire</button></p>";
}

async function display_client_waiting_job(job)
{
	const contract = dapp.contract;
	let nb_candidates = (await contract.nb_candidates(job._hash)).toNumber();
	let candidates = "";

	for (var i = 0; i < nb_candidates; i++)
	{
		let artist = await dapp.contract.job_candidate(job._hash, i);
		candidates += candidate_markups(artist._name, artist._reputation, artist._address, job._hash);
	}

	document.getElementById('waiting_jobs').innerHTML += "<div class='job' id='w_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "<div id='c_job_" + job._hash + "''>" + candidates + "</div>"
		+ "<button onclick='cancel_job(\"" + job._hash + "\")'>Cancel</button>"
		+ "</div>";
}

function display_artist_waiting_job(job)
{
	document.getElementById('waiting_jobs').innerHTML += "<div class='job' id='w_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "<button onclick='candidate_for_job(\"" + job._hash + "\")'>Candidate</button>"
		+ "</div>";
}

function display_client_ongoing_job(job)
{
	document.getElementById('ongoing_jobs').innerHTML += "<div class='job' id='o_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "</div>";
}

function display_artist_ongoing_job(job)
{
	document.getElementById('ongoing_jobs').innerHTML += "<div class='job' id='o_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "<input type='text' id='deliver_" + job._hash + "' />"
		+ "<button onclick='deliver_job(\"" + job._hash + "\")'>Deliver</button>"
		+ "</div>";
}

function display_client_finished_job(job)
{
	document.getElementById('finished_jobs').innerHTML += "<div class='job' id='f_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "<button onclick='close_job(\"" + job._hash + "\")'>Close</button>"
		+ "<button onclick='blame_artist(\"" + job._hash + "\")'>Blame artist</button>"
		+ "</div>";
}

function display_artist_finished_job(job)
{
	document.getElementById('finished_jobs').innerHTML += "<div class='job' id='f_job_" + job._hash + "'>"
		+ job_to_xhtml(job)
		+ "</div>";
}

function display_client_job(job)
{
	console.log("Handling job, ", job._hash, ": ", job._status);

	if(job._issuer.toLowerCase() == dapp.address)
	{
		if(job._status == JobStatus.WAITING)
		{
			display_client_waiting_job(job);
		}
		else if(job._status == JobStatus.ONGOING)
		{
			display_client_ongoing_job(job);
		}
		else if(job._status == JobStatus.FINISHED)
		{
			display_client_finished_job(job);
		}
		else
		{
			console.log("Uknown job status, ", job._hash, ": ", job._status);
		}
	}
}

function display_artist_job(job)
{
	console.log("Handling job, ", job._hash, ": ", job._status);

	if(job._status == JobStatus.WAITING)
	{
		display_artist_waiting_job(job);
	}
	else if(job._taker.toLowerCase() == dapp.address)
	{
		if(job._status == JobStatus.ONGOING)
		{
			display_artist_ongoing_job(job);
		}
		else if(job._status == JobStatus.FINISHED)
		{
			display_artist_finished_job(job);
		}
	}
}

async function find_job(job_hash)
{
	return await dapp.contract.find_job(job_hash);
}

async function update_client_waiting_jobs(job_hash)
{
	const job = await find_job(job_hash);
	display_client_waiting_job(job);
}

async function add_job_candidate(candidate, job_hash)
{
	const job = await find_job(job_hash);

	if (job._issuer.toLowerCase() == dapp.address)
	{
		const artist = await dapp.contract._artists(candidate);
		document.getElementById("c_job_" + job_hash).innerHTML +=
			candidate_markups(artist._name, artist._reputation, candidate, job_hash);
	}
}

async function update_artist_waiting_jobs(job_hash)
{
	const job = await find_job(job_hash);
	display_artist_waiting_job(job);
}

async function update_client_ongoing_jobs(job_hash)
{
	const job = await find_job(job_hash);

	if (job._issuer.toLowerCase() == dapp.address)
	{
		console.log("Issuer is current client");
		display_client_ongoing_job(job);
		remove_element_by_id("w_job_" + job_hash);
	}
}

async function update_artist_ongoing_jobs(job_hash)
{
	const job = await find_job(job_hash);
	display_artist_ongoing_job(job);
	remove_element_by_id("w_job_" + job_hash);
}

async function update_client_finished_jobs(job_hash)
{
	const job = await find_job(job_hash);

	if (job._issuer.toLowerCase() == dapp.address)
	{
		display_client_finished_job(job);
		remove_element_by_id("o_job_" + job_hash);
	}
}

async function update_artist_finished_jobs(job_hash)
{
	const job = await find_job(job_hash);

	if (job._taker.toLowerCase() == dapp.address)
	{
		display_artist_finished_job(job);
		remove_element_by_id("o_job_" + job_hash);
	}
}

async function is_registered_client()
{
	return false == (await dapp.contract._clients(dapp.address))._reputation.isZero();
}

async function is_registered_artist()
{
	dapp.artist = await dapp.contract._artists(dapp.address);
	return false == dapp.artist._reputation.isZero();
}

async function get_all_client_jobs()
{
	let i = 0;
	document.getElementById('waiting_jobs').innerHTML = "";
	document.getElementById('ongoing_jobs').innerHTML = "";
	document.getElementById('finished_jobs').innerHTML = "";

	while (true)
	{
		try
		{
			const job = await dapp.contract._jobs(i);
			display_client_job(job);
			++i;
		}
		catch(err)
		{
			break;
		}
	}
}

function show_artist_info()
{
	document.getElementById('info_name').innerHTML = dapp.artist._name;
	document.getElementById('info_reputation').innerHTML = dapp.artist._reputation.toString();
}

async function get_all_artist_jobs()
{
	let i = 0;
	document.getElementById('waiting_jobs').innerHTML = "";
	document.getElementById('ongoing_jobs').innerHTML = "";
	document.getElementById('finished_jobs').innerHTML = "";

	while (true)
	{
		try
		{
			const job = await dapp.contract._jobs(i);
			display_artist_job(job);
			++i;
		}
		catch(err)
		{
			break;
		}
	}
}

async function update_client_view()
{
	await establish_dapp_connection();

	if (await is_registered_client())
	{
		document.getElementById('register_form').style.display = 'none';
		document.getElementById('submit_form').style.display = 'inline';
		get_all_client_jobs();

		dapp.contract.on("JobSubmitted", (title, issuer, job_hash, event) => {
			console.log("New job: ", title, " ", job_hash);

			if(issuer.toLowerCase() == dapp.address)
			{
				console.log("Issuer is current client");
				update_client_waiting_jobs(job_hash);
			}		
		});

		dapp.contract.on("JobCandidated", (name, candidate, job_hash, event) => {
			console.log("New candidate: ", candidate, " for ", job_hash);
			add_job_candidate(candidate, job_hash);
		});

		dapp.contract.on("JobHire", (hire, job_hash, event) => {
			console.log("New Hire: ", hire, " for ", job_hash);
			update_client_ongoing_jobs(job_hash);
		});

		dapp.contract.on("JobFinished", (delivery_url, job_hash, event) => {
			console.log("Job finished: ", delivery_url, " for ", job_hash);
			update_client_finished_jobs(job_hash);
		});
	}
	else
	{
		document.getElementById('register_form').style.display = 'inline';
		document.getElementById('submit_form').style.display = 'none';
	}
}

async function update_artist_view()
{
	await establish_dapp_connection();

	if (await is_registered_artist())
	{
		document.getElementById('register_form').style.display = 'none';
		document.getElementById('info').style.display = 'inline';
		show_artist_info();
		get_all_artist_jobs();

		dapp.contract.on("JobSubmitted", (title, issuer, job_hash, event) => {
			console.log("New job: ", title, " ", job_hash);

			if(issuer.toLowerCase() == dapp.address)
			{
				console.log("Issuer is current client");
				update_artist_waiting_jobs(job_hash);
			}
		});

		dapp.contract.on("JobHire", (hire, job_hash, event) => {
			console.log("New Hire: ", hire, " for ", job_hash);

			if (hire.toLowerCase() == dapp.address)
			{
				console.log("Hire is current client");
				update_artist_ongoing_jobs(job_hash);
			}
		});

		dapp.contract.on("JobFinished", (delivery_url, job_hash, event) => {
			console.log("Job finished: ", delivery_url, " for ", job_hash);
			update_artist_finished_jobs(job_hash);
		});
	}
	else
	{
		document.getElementById('register_form').style.display = 'inline';
		document.getElementById('info').style.display = 'none';
	}
}

async function register_as_client()
{
	await establish_dapp_connection();

	if( false == await is_registered_client() )
	{
		const client_name = document.getElementById('client_name').value;
		console.log("Registering: ", client_name);
		const tx = await dapp.contract.register_client(client_name);
		tx.wait().then(() =>
			{
				console.log("Registered: ", client_name);
				update_client_view();
			});
	}
}

async function register_as_artist()
{
	await establish_dapp_connection();

	if( false == await is_registered_artist() )
	{
		const artist_name = document.getElementById('artist_name').value;
		console.log("Registering: ", artist_name);
		const tx = await dapp.contract.register_artist(artist_name);
		tx.wait().then(() =>
			{
				console.log("Registered: ", artist_name);
				update_artist_view();
			});
	}
}

async function submit_job()
{
	document.getElementById('job_submit_result').innerHTML = "";

	const job_pay = document.getElementById('job_pay').value;
	const job_reputation = document.getElementById('job_reputation').value;
	const job_time = document.getElementById('job_time').value;
	const job_title = document.getElementById('job_title').value;
	const job_desciption = document.getElementById('job_desciption').value;

	let overrides = {
		value: ethers.utils.parseEther(job_pay),
	};

	const tx = await dapp.contract.submit_job(
		job_title,
		job_desciption,
		job_reputation,
		job_time * SECONDS_IN_ONE_HOUR,
		overrides);
	tx.wait();
	// TODO fill job_submit_result
}

async function cancel_job(job_hash)
{
	const contract = dapp.contract;
	const tx = await contract.cancel_job(job_hash);

	tx.wait().then((tx_result) =>
		{
			if(tx_result.status > 0)
			{
				remove_element_by_id("w_job_" + job_hash);
			}
		}
	);
}

async function candidate_for_job(job_hash)
{
	const contract = dapp.contract;
	const tx = await contract.candidate_for_job(job_hash);
	tx.wait();
}

async function hire(job_hash, address)
{
	const contract = dapp.contract;
	const tx = await contract.hire(job_hash, address);
	tx.wait();
}

async function deliver_job(job_hash)
{
	const delivery_url = document.getElementById('deliver_' + job_hash).value;
	const contract = dapp.contract;
	const tx = await contract.deliver_job(job_hash, delivery_url);
	tx.wait();
}

async function call_close_job(job_hash, apply_blame)
{
	const contract = dapp.contract;
	const tx = await contract.close_job(job_hash, apply_blame);
	tx.wait().then((tx_result) =>
		{
			if(tx_result.status > 0)
			{
				remove_element_by_id("f_job_" + job_hash);
			}
		}
	);
}

async function close_job(job_hash)
{
	await call_close_job(job_hash, false);
}

async function blame_artist(job_hash)
{
	await call_close_job(job_hash, true);
}
