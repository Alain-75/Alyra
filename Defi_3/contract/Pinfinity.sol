pragma solidity ^0.5.4;

contract Pinfinity
{
	uint constant public _pin_cost = 1 finney;
	address payable private _owner;

	constructor() public
	{
		_owner = msg.sender;
	}

	event Pin(address origin, string indexed ipfs_file_id);
	
	function pay_storage(string memory ipfs_file_id) public payable
	{
		require(msg.value >= _pin_cost, "You must pay for storage");
		emit Pin(msg.sender, ipfs_file_id);
		_owner.transfer(msg.value);
	}
}