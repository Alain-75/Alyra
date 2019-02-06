pragma solidity ^0.5.3;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Credibility
{
	using SafeMath for uint256;

	mapping (address => uint256) public _cred;

	bytes32[] private _homeworks;

	function produce_hash(string memory homework) public pure returns(bytes32 homework_hash)
	{
		return keccak256(abi.encodePacked(homework));
	}

	function transfer(address recipient, uint256 credibility) public
	{
		// entails that _cred[msg.sender] > 0
		require(_cred[msg.sender] > credibility, "Sender is not credible enough.");
		require(_cred[recipient] > 0, "Recipient is not credible.");

		_cred[msg.sender] -= credibility; // underflow not possible
		_cred[recipient] = _cred[recipient].add(credibility);
	}

	function turn_in(bytes32 homework_hash) public returns(uint position)
	{
		require(_cred[msg.sender] == 0, "Already turned in your homework.");
		uint nb_already_turned_in = _homeworks.length;

		for (uint i = 0; i < nb_already_turned_in; i++)
		{
			require(homework_hash != _homeworks[i], "Cheater!");
		}

		_homeworks.push(homework_hash);

		if (nb_already_turned_in > 1)
		{
			_cred[msg.sender] = 10;
		}
		else if (nb_already_turned_in == 1)
		{
			_cred[msg.sender] = 20;
		}
		else if (nb_already_turned_in == 0)
		{
			_cred[msg.sender] = 30;
		}

		return nb_already_turned_in + 1;
	}
}
