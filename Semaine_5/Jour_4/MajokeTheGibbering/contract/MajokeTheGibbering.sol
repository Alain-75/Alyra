pragma solidity ^0.5.4;

contract MajokeTheGibbering
{
	address payable private _owner;
	uint256 public _card_registering_cost;
	bytes32[] public _card_hashes;
	mapping(bytes32 => string) public _card_names;
	mapping(string => bytes32) private _reverse_card_names;

	constructor(uint256 card_registering_cost) public
	{
		_owner = msg.sender;
		_card_registering_cost = card_registering_cost;
	}

	function nb_cards() public view returns(uint256 nb_cards)
	{
		return _card_hashes.length;
	}

	function register_card(string memory name, bytes32 hash) public payable
	{
		require(msg.value >= _card_registering_cost, "Thou shalt payeth");
		require(bytes(name).length > 0, "Gimmme a proper name");
		require(bytes(_card_names[hash]).length == 0, "Card already exists");
		require(_reverse_card_names[name] == bytes32(0), "Name already given");

		_card_hashes.push(hash);
		_card_names[hash] = name;
		_reverse_card_names[name] = hash;
		_owner.transfer(_card_registering_cost);
	}

    function card_from_name(string memory name) public view returns (bytes32 card_hash)
    {
        return _reverse_card_names[name];
    }
}