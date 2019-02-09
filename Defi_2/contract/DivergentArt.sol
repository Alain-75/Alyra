pragma solidity ^0.5.3;
pragma experimental ABIEncoderV2;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract DivergentArt
{
	using SafeMath for uint;

	address payable _owner;
	constructor() public { _owner = msg.sender; }
	function () payable external { _owner.transfer(msg.value); }

	struct Entity
	{
		string _name;
		uint _reputation;
	}

	struct AddressedEntity
	{
		address _address;
		string _name;
		uint _reputation;
	}

	enum Status{
		WAITING,
		ONGOING,
		FINISHED
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
		Status _status;
	}

	mapping (address => Entity) public _artists;
	mapping (address => Entity) public _clients;
	address[] private _blacklist;

	Job[] public _jobs;

	uint constant private MAX_UINT256 = ~uint256(0);
	uint constant private NO_REPUTATION = 0;
	uint constant public MINIMUM_JOB_PAY = 100 wei;

	event JobSubmitted(string title, address issuer, bytes32 job_hash);
	event JobCandidated(string name, address candidate, bytes32 job_hash);
	event JobHire(address hire, bytes32 job_hash);
	event JobResigned(bytes32 job_hash);
	event JobFinished(string delivery_url, bytes32 job_hash);

	function _job_index(bytes32 job_hash) internal view returns(uint index_or_not)
	{
		for (uint i = 0; i < _jobs.length; ++i)
		{
			if (_jobs[i]._hash == job_hash)
			{
				return i;
			}
		}

		return MAX_UINT256;
	}

	function _find_job(bytes32 job_hash) internal view returns(Job storage)
	{
		uint index = _job_index(job_hash);
		require(index != MAX_UINT256, "Unknown job");
		return _jobs[index];
	}

	function _remove_job_at_index(uint index) internal
	{
		delete _jobs[index];

		for (uint i = index; i < _jobs.length - 1; ++i)
		{
			_jobs[i] = _jobs[i + 1];
		}

		_jobs.length -= 1;
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
	}

	function _blame_artist(Job storage job, bool apply_blame) internal
	{
		if ( apply_blame && address(0) != job._taker && (job._delivery_time - job._take_time) > job._delay_seconds )
		{
			Entity storage artist = _artists[job._taker];
			artist._reputation = _change_reputation(artist._reputation, -1);
			job._taker = address(0);
		}
	}

	function _register(Entity storage entity, string memory name) internal
	{		
		if (entity._reputation == 0)
		{
			entity._name = name;
			entity._reputation = 1;
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
		_register(_artists[msg.sender], name);
	}

	function register_client(string memory name) public not_blacklisted
	{
		_register(_clients[msg.sender], name);
	}

	function blacklist(address someone) external
	{
		require(msg.sender == _owner);
		_blacklist.push(someone);
		_artists[someone]._reputation = 0;
		_clients[someone]._reputation = 0;
	}

	function find_job(bytes32 job_hash) public view returns(Job memory)
	{
		return _find_job(job_hash);
	}

	function nb_candidates(bytes32 job_hash) public view returns(uint nb)
	{
		return _find_job(job_hash)._candidates.length;
	}

	function job_candidate(bytes32 job_hash, uint index) public view returns(AddressedEntity memory candidate)
	{
		AddressedEntity memory cand;
		cand._address = _find_job(job_hash)._candidates[index];
		Entity memory artist = _artists[cand._address];
		cand._name = artist._name;
		cand._reputation = artist._reputation;
		return cand;
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
		job._status = Status.WAITING;

		_jobs.push(job);
		_owner.transfer(fee);
		emit JobSubmitted(job._title, job._issuer, job._hash);
	}

	function cancel_job(bytes32 job_hash) public registered_client
	{
		uint index = _job_index(job_hash);
		require(index != MAX_UINT256, "Unknown job");
		Job memory job = _jobs[index];
		require(job._status == Status.WAITING, "Cannot cancel");
		require(job._issuer == msg.sender, "Not your job");
		_remove_job_at_index(index);
		msg.sender.transfer(job._pay); // refund pay but not fees
	}

	function candidate_for_job(bytes32 job_hash) public registered_artist
	{
		Entity memory artist = _artists[msg.sender];
		Job storage job = _find_job(job_hash);
		require(job._status == Status.WAITING, "Cannot candidate");
		require(artist._reputation >= job._required_reputation, "Not reputed enough");
		job._candidates.push(msg.sender);
		emit JobCandidated(artist._name, msg.sender, job_hash);
	}

	function hire(bytes32 job_hash, address artist) public registered_client
	{
		Job storage job = _find_job(job_hash);
		require(job._status == Status.WAITING, "Cannot hire");
		require(job._issuer == msg.sender, "You are not the issuer");
		require(_has_candidated_for_job(artist, job), "Not a candidate");
		job._taker = artist;
		job._take_time = now;
		job._status = Status.ONGOING;
		emit JobHire(artist, job_hash);
	}

	function give_up_job(bytes32 job_hash) public registered_artist
	{
		Job storage job = _find_job(job_hash);
		require(job._status == Status.ONGOING, "Cannot give up");
		require(job._taker == msg.sender, "Not your job");
		job._taker = address(0);
		job._take_time = 0;
		job._status = Status.WAITING;
		// Do not reduce artist reputation for giving up
		// in order to disincentive making bad deliveries.
		emit JobResigned(job_hash);
	}

	function deliver_job(bytes32 job_hash, string memory delivery_url) public registered_artist
	{
		Job storage job = _find_job(job_hash);
		require(job._status == Status.ONGOING, "Cannot deliver");
		require(job._taker == msg.sender, "Not your job");
		job._delivery_url_hash = keccak256(abi.encodePacked(delivery_url));
		job._delivery_time = now;
		job._status = Status.FINISHED;
		delete job._candidates;
		msg.sender.transfer(job._pay);
		Entity storage artist = _artists[msg.sender];
		artist._reputation = _change_reputation(artist._reputation, 1);
		emit JobFinished(delivery_url, job_hash);
	}

	function close_job(bytes32 job_hash, bool apply_blame) public registered_client
	{
		uint index = _job_index(job_hash);
		require(index != MAX_UINT256, "Unknown job");
		Job storage job = _jobs[index];
		require(job._status == Status.FINISHED, "Cannot close");
		require(job._issuer == msg.sender, "Not your job");
		_blame_artist(job, apply_blame);
		_remove_job_at_index(index);
	}

	function renew_job(bytes32 job_hash, bool apply_blame) public registered_client
	{
		Job storage job = _find_job(job_hash);
		require(job._status == Status.FINISHED, "Cannot deliver");
		require(job._issuer == msg.sender, "You are not the issuer");
		job._taker = address(0);
		job._take_time = 0;
		job._delivery_time = 0;
		job._delivery_url_hash = bytes32(0);
		_blame_artist(job, apply_blame);
		emit JobSubmitted(job._title, job._issuer, job._hash);
	}
}