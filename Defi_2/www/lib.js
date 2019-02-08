let dapp = null;

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
		"constant": true,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "finished_job",
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
						"name": "_blame_issued",
						"type": "bool"
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
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "_finished_jobs",
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
				"name": "_blame_issued",
				"type": "bool"
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
		"payable": true,
		"stateMutability": "payable",
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
				"type": "uint256"
			}
		],
		"name": "_ongoing_jobs",
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
				"name": "_blame_issued",
				"type": "bool"
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
		"name": "_waiting_jobs",
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
				"name": "_blame_issued",
				"type": "bool"
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
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "waiting_job",
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
						"name": "_blame_issued",
						"type": "bool"
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
		"constant": true,
		"inputs": [
			{
				"name": "job_hash",
				"type": "bytes32"
			}
		],
		"name": "ongoing_job",
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
						"name": "_blame_issued",
						"type": "bool"
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
		"constant": true,
		"inputs": [],
		"name": "JOB_INDEX_NOT_FOUND",
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
		"inputs": [],
		"name": "MAX_REPUTATION",
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
			}
		],
		"name": "candidate_for_job",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
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

const DIVERGENT_ADDRESS = "";

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
		const contract = new ethers.Contract(DIVERGENT_ADDRESS, DIVERGENT_ABI, provider.getSigner());
		dapp = { address, provider, contract };
		console.log("Dapp is connected.");
	}
	catch(err)
	{
		dapp = {};
		console.error(err);
	}
}

let waiting_jobs = [];
let ongoing_jobs = [];
let finished_jobs = [];

async function udpate_waiting_jobs()
{
	document.getElementById('waiting_jobs').innerHTML = "";
	console.log(waiting_jobs);
}

async function update_ongoing_jobs()
{
	document.getElementById('ongoing_jobs').innerHTML = "";
}

async function update_finished_jobs()
{
	document.getElementById('finished_jobs').innerHTML = "";
}

async function update_view(is_client)
{

}

async function register_as_client()
{
	if (false == dapp_is_on())
	{
		establish_dapp_connection();
	}

	const contract = dapp.contract;
	const reputation = await contract._clients(dapp.address);

	if (reputation == 0)
	{
		const tx = await contract.register_client();
		tx.wait();
	}

	contract.on("JobSubmitted", (title, issuer, job_hash) => {
		if(issuer == dapp.address)
		{
			const job = await contract.waiting_job(job_hash);
			waiting_jobs.push(job);
			udpate_waiting_jobs();
		}		
	});
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
		job_time * SECONDS_IN_ONE_HOUR
		overrides);
	tx.wait();
}

async function register_as_artist()
{

}
