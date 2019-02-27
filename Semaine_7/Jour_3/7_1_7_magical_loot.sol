pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

contract Loot
{
	mapping(uint256 => address) _loot_ownership;

	enum Occurence
	{
		COMMON,
		RARE,
		DIVINE,
		MAX_OCCURENCE
	}

	enum Type
	{
		ARMOR,
		WEAPON,
		WAND,
		MAX_TYPE
	}

	struct Object
	{
		Occurence _occurence;
		Type _type;
		uint8 _number;
	}

	uint256 constant MAX_NUMBER = 100;
	uint256 constant OCCURENCE_SHIFT = 1000;
	uint256 constant TYPE_SHIFT = 100;
	uint256 constant MAX_TOKEN = MAX_OCCURENCE*OCCURENCE_SHIFT + MAX_TYPE*TYPE_SHIFT + MAX_NUMBER;

	function Tokenize(Object memory loot) public pure returns(uint256 token)
	{
		require(loot._occurence < MAX_OCCURENCE);
		require(loot._type < MAX_TYPE);
		require(loot._number < MAX_NUMBER);
		return loot._occurence*OCCURENCE_SHIFT + loot._type*TYPE_SHIFT + loot._number;
	}

	function Objectify(uint256 token) public pure returns(uint256 token)
	{
		require(loot._number <= 99 );
		return loot._occurence*1000 + loot._type*100 + loot._number;
	}


}