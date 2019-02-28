pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

contract Loot
{
	mapping(uint256 => address) _loot_ownership;

	uint8 constant OCCURENCE_COMMON = 0;
	uint8 constant OCCURENCE_RARE = 1;
	uint8 constant OCCURENCE_DIVINE = 2;
	uint8 constant MAX_OCCURENCE = 3;

	uint8 constant ARMOR = 0;
	uint8 constant WEAPON = 1;
	uint8 constant WAND = 2;
	uint8 constant MAX_TYPE = 3;

	uint8 constant MAX_NUMBER = 100;

	struct Object
	{
		uint8 _occurence;
		uint8 _type;
		uint8 _number;
	}

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

	function GetOccurence(uint256 token) public pure returns(uint256)
	{
		uint256 occurence = token / 1000;
		require(occurence < MAX_OCCURENCE);
		return occurence;
	}

	function GetType(uint256 token) public pure returns(uint256)
	{
		uint256 type_ = (token / 100) % 10;
		require(type_ < MAX_TYPE);
		return type_;
	}

	function GetNumber(uint256 token) public pure returns(uint256)
	{
		return token % 100;
	}

	function Objectify(uint256 token) public pure returns(Object memory)
	{
		Object memory loot;
		loot._occurence = uint8(GetOccurence(token));
		loot._type = uint8(GetType(token));
		loot._number = uint8(GetNumber(token));
		return loot;
	}


}