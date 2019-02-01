pragma solidity ^0.5.2;

contract Pulsation
{
	uint public _beat;
	string private _message;

	constructor(string memory message) public
	{
		_message = message;
	}

	function add_beat() public returns(string memory message)
	{
		_beat++;
		return _message;
	}
}

contract Clock is Pulsation("Tic")
{
	string[2] public _tac_tic;
	uint8 internal _time_for_tic;
	Pulsation internal _tac;

	function add_tac(Pulsation t) public
	{
		_tac = t;
	}

	function induce_beat() public
	{
		if (_time_for_tic == 1)
		{
			_tac_tic[_time_for_tic] = add_beat();
			_time_for_tic = 0;
		}
		else
		{
			_tac_tic[_time_for_tic] = _tac.add_beat();
			_time_for_tic = 1;
		}
	}
}
