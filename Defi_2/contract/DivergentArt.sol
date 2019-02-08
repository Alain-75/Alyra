pragma solidity ^0.5.3;
pragma experimental ABIEncoderV2;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract DivergentArt
{
	using SafeMath for uint;

	struct Artist
	{
		string _name;
		uint _reputation;
	}

	struct Client
	{
		string _name;
		uint _reputation;
	}

	struct Job
	{
		address _issuer;
		string _title;
		string _description;
		uint _pay;
		uint _required_reputation;
		bytes32 _hash;
		address[] _candidates;
		address _taker;
		uint _delay_seconds;
		uint _take_time;
		uint _delivery_time;
		bytes32 _delivery_url_hash;
		bool _blame_issued;
	}

	mapping (address => Artist) public _artists;
	mapping (address => Client) public _clients;
	address[] private _blacklist;

	Job[] public _waiting_jobs;
	Job[] public _ongoing_jobs;
	Job[] public _finished_jobs;

	uint constant private MAX_UINT256 = ~uint256(0);
	uint constant public MAX_REPUTATION = MAX_UINT256;
	uint constant public JOB_INDEX_NOT_FOUND = MAX_UINT256;
	uint constant private NO_REPUTATION = 0;
	uint constant public MINIMUM_JOB_PAY = 100 wei;

	event JobSubmitted(string title, address issuer, bytes32 job_hash);
	event JobCandidated(string name, address candidate, bytes32 job_hash);
	event JobHire(address hire, bytes32 job_hash);
	event JobResigned(bytes32 job_hash);
	event JobFinished(string delivery_url, bytes32 job_hash);

	function _job_index(Job[] memory array, bytes32 job_hash) internal pure returns(uint index_or_not)
	{
		for (uint i = 0; i < array.length; ++i)
		{
			if (array[i]._hash == job_hash)
			{
				return i;
			}
		}

		return JOB_INDEX_NOT_FOUND;
	}

	function _find_job(Job[] storage array, bytes32 job_hash) internal view returns(Job storage)
	{
		uint index = _job_index(array, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		return array[index];
	}

	function _remove_job_at_index(Job[] storage array, uint index) internal
	{
		delete array[index];

		for (uint i = index; i < array.length - 1; ++i)
		{
			array[i] = array[i + 1];
		}
	}

	function _change_reputation(uint reputation, int change) internal pure returns(uint new_reputation)
	{
		uint result = uint(int(reputation) + change);

		if (change > 0 && result < reputation)
		{
			return MAX_UINT256;
		}
		else if (change < 0 && result > reputation)
		{
			return 0;
		}

		return result;
	}

	function _is_blacklisted(address somebody) internal view returns(bool banned)
	{
		for (uint i = 0; i < _blacklist.length; ++i)
		{
			if (_blacklist[i] == somebody)
			{
				return true;
			}
		}

		return false;
	}

	function _has_candidated_for_job(address artist, Job memory job) internal pure returns(bool)
	{
		for (uint i = 0; i < job._candidates.length; ++i)
		{
			if(artist == job._candidates[i])
			{
				return true;
			}
		}
		return false;
	}

	function _blame_artist(Job memory job, bool apply_blame) internal
	{
		if ( apply_blame && false == job._blame_issued && (job._delivery_time - job._take_time) > job._delay_seconds )
		{
			Artist storage artist = _artists[job._taker];
			artist._reputation = _change_reputation(artist._reputation, -1);
			job._blame_issued = true;
		}
	}

	modifier not_blacklisted()
	{
		require(false == _is_blacklisted(msg.sender), "You are blacklisted");
		_;
	}

	modifier registered_artist()
	{
		require(_artists[msg.sender]._reputation > 0, "You are not registered as an artist");
		_;
	}

	modifier registered_client()
	{
		require(_clients[msg.sender]._reputation > 0, "You are not registered as a client");
		_;
	}

	function register_artist(string memory name) public not_blacklisted
	{
		Artist storage artist = _artists[msg.sender];
		
		if (artist._reputation == 0)
		{
			artist._name = name;
			artist._reputation = 1;
		}
	}

	function register_client(string memory name) public not_blacklisted
	{
		Client storage client = _clients[msg.sender];
		
		if (client._reputation == 0)
		{
			client._name = name;
			client._reputation = 1;
		}
	}

	function waiting_job(bytes32 job_hash) public view returns(Job memory)
	{
		return _find_job(_waiting_jobs, job_hash);
	}

	function ongoing_job(bytes32 job_hash) public view returns(Job memory)
	{
		return _find_job(_ongoing_jobs, job_hash);
	}

	function finished_job(bytes32 job_hash) public view returns(Job memory)
	{
		return _find_job(_finished_jobs, job_hash);
	}

	function submit_job(
			string memory title
		,	string memory description
		,	uint required_reputation
		,	uint delay_seconds
		) public payable registered_client
	{
		require(msg.value >= MINIMUM_JOB_PAY, "You have to pay at least 100 wei.");

		uint fee = (msg.value.mul(2)).div(100);

		Job memory job;
		job._issuer = msg.sender;
		job._title = title;
		job._description = description;
		job._pay = msg.value - fee;
		job._required_reputation = required_reputation;
		job._hash = keccak256(abi.encodePacked(
				job._issuer
			,	job._title
			,	job._description
			,	job._pay
			,	job._required_reputation
			));
		job._taker = address(0);
		job._take_time = 0;
		job._delay_seconds = delay_seconds;
		job._delivery_time = 0;
		job._blame_issued = false;

		_waiting_jobs.push(job);
		emit JobSubmitted(job._title, job._issuer, job._hash);
	}

	function cancel_job(bytes32 job_hash) public registered_client
	{
		uint index = _job_index(_waiting_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_waiting_jobs[index]._issuer == msg.sender, "Not your job");
		_remove_job_at_index(_waiting_jobs, index);
	}

	function candidate_for_job(bytes32 job_hash) public registered_artist
	{
		Artist memory artist = _artists[msg.sender];
		uint index = _job_index(_waiting_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		Job storage job = _waiting_jobs[index];
		require(artist._reputation >= job._required_reputation, "Not reputed enough");
		job._candidates.push(msg.sender);
		emit JobCandidated(artist._name, msg.sender, job_hash);
	}

	function hire(bytes32 job_hash, address artist) public registered_client
	{
		uint index = _job_index(_waiting_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_waiting_jobs[index]._issuer == msg.sender, "You are not the issuer");

		_ongoing_jobs.push(_waiting_jobs[index]);
		_remove_job_at_index(_waiting_jobs, index);

		Job storage job = _ongoing_jobs[_ongoing_jobs.length - 1];
		require(_has_candidated_for_job(artist, job), "Not a candidate");
		job._taker = artist;
		job._take_time = now;
		emit JobHire(artist, job_hash);
	}

	function give_up_job(bytes32 job_hash) public registered_artist
	{
		uint index = _job_index(_ongoing_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_ongoing_jobs[index]._taker == msg.sender, "Not your job");

		_waiting_jobs.push(_ongoing_jobs[index]);
		_remove_job_at_index(_ongoing_jobs, index);

		Job storage job = _waiting_jobs[_waiting_jobs.length - 1];
		job._taker = address(0);
		job._take_time = 0;
		// Do not reduce artist reputation for giving up
		// in order to disincentive making bad deliveries.
		emit JobResigned(job_hash);
	}

	function deliver_job(bytes32 job_hash, string memory delivery_url) public registered_artist
	{
		uint index = _job_index(_ongoing_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_ongoing_jobs[index]._taker == msg.sender, "Not your job");

		_finished_jobs.push(_ongoing_jobs[index]);
		_remove_job_at_index(_ongoing_jobs, index);

		Job storage job = _finished_jobs[_finished_jobs.length - 1];
		job._delivery_url_hash = keccak256(abi.encodePacked(delivery_url));
		job._delivery_time = now;
		msg.sender.transfer(job._pay);
		Artist storage artist = _artists[msg.sender];
		artist._reputation = _change_reputation(artist._reputation, 1);
		emit JobFinished(delivery_url, job_hash);
	}

	function close_job(bytes32 job_hash, bool apply_blame) public registered_client
	{
		uint index = _job_index(_finished_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_finished_jobs[index]._issuer == msg.sender, "You are not the issuer");
		_blame_artist(_finished_jobs[index], apply_blame);
		_remove_job_at_index(_finished_jobs, index);
	}

	function renew_job(bytes32 job_hash, bool apply_blame) public registered_client
	{
		uint index = _job_index(_finished_jobs, job_hash);
		require(index != JOB_INDEX_NOT_FOUND, "Unknown job");
		require(_finished_jobs[index]._issuer == msg.sender, "You are not the issuer");

		_waiting_jobs.push(_finished_jobs[index]);
		_remove_job_at_index(_finished_jobs, index);

		Job storage job = _waiting_jobs[_waiting_jobs.length - 1];
		_blame_artist(job, apply_blame);
		job._taker = address(0);
		job._take_time = 0;
		job._delivery_time = 0;
		job._blame_issued = false;
		job._delivery_url_hash = bytes32(0);
		emit JobSubmitted(job._title, job._issuer, job._hash);
	}
}