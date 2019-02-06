pragma solidity ^0.5.3;

import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract MinimalToken
{
	using SafeMath for uint;

	address _owner;
	mapping(address => uint) public _accounts;

	modifier require_owner()
	{
		require(msg.sender == _owner, "Only contract owner can do that.");
		_;
	}

	constructor(uint starting_tokens) public
	{
		_owner = msg.sender;
		_accounts[msg.sender] = starting_tokens;
	}

	function transfer(address recipient, uint amount) public
	{
		require(amount > 0, "You have to transfer at least 1 token.");
		require(amount <= _accounts[msg.sender], "Not enough token to transfer.");

		_accounts[recipient] = _accounts[recipient].add(amount);
		_accounts[msg.sender] = _accounts[msg.sender].sub(amount);
	}

	function mint(uint amount) public require_owner
	{
		require(amount > 0, "You have to mint at least 1 token.");
		_accounts[msg.sender] = _accounts[msg.sender].add(amount);
	}

	function mint_and_transfer(address recipient, uint amount) public require_owner
	{
		require(amount > 0, "You have to mint at least 1 token.");
		_accounts[recipient] = _accounts[recipient].add(amount);
	}
}
