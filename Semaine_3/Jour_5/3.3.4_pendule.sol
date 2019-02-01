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
	string[] public _tac_tic;
	Pulsation internal _tic;
	Pulsation internal _tac;

	constructor() public
	{
		_tic = new Pulsation("Tic");
		_tac = new Pulsation("Tac");
	}

	function induce_beat(uint k) public
	{
		while ( k > 0 )
		{
			if ( k % 2 == 0 )
			{
				_tac_tic.push( _tic.add_beat() );
			}
			else
			{
				_tac_tic.push( _tac.add_beat() );
			}

			--k;
		}
	}
}
