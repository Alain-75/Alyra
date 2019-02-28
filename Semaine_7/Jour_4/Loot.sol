pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
interface ERC721 /* is ERC165 */ {
	/// @dev This emits when ownership of any NFT changes by any mechanism.
	///  This event emits when NFTs are created (`from` == 0) and destroyed
	///  (`to` == 0). Exception: during contract creation, any number of NFTs
	///  may be created and assigned without emitting Transfer. At the time of
	///  any transfer, the approved address for that NFT (if any) is reset to none.
	event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

	/// @dev This emits when the approved address for an NFT is changed or
	///  reaffirmed. The zero address indicates there is no approved address.
	///  When a Transfer event emits, this also indicates that the approved
	///  address for that NFT (if any) is reset to none.
	event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

	/// @dev This emits when an operator is enabled or disabled for an owner.
	///  The operator can manage all NFTs of the owner.
	event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

	/// @notice Count all NFTs assigned to an owner
	/// @dev NFTs assigned to the zero address are considered invalid, and this
	///  function throws for queries about the zero address.
	/// @param _owner An address for whom to query the balance
	/// @return The number of NFTs owned by `_owner`, possibly zero
	function balanceOf(address _owner) external view returns (uint256);

	/// @notice Find the owner of an NFT
	/// @dev NFTs assigned to zero address are considered invalid, and queries
	///  about them do throw.
	/// @param _tokenId The identifier for an NFT
	/// @return The address of the owner of the NFT
	function ownerOf(uint256 _tokenId) external view returns (address);

	/// @notice Transfers the ownership of an NFT from one address to another address
	/// @dev Throws unless `msg.sender` is the current owner, an authorized
	///  operator, or the approved address for this NFT. Throws if `_from` is
	///  not the current owner. Throws if `_to` is the zero address. Throws if
	///  `_tokenId` is not a valid NFT. When transfer is complete, this function
	///  checks if `_to` is a smart contract (code size > 0). If so, it calls
	///  `onERC721Received` on `_to` and throws if the return value is not
	///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
	/// @param _from The current owner of the NFT
	/// @param _to The new owner
	/// @param _tokenId The NFT to transfer
	/// @param data Additional data with no specified format, sent in call to `_to`
	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

	/// @notice Transfers the ownership of an NFT from one address to another address
	/// @dev This works identically to the other function with an extra data parameter,
	///  except this function just sets data to ""
	/// @param _from The current owner of the NFT
	/// @param _to The new owner
	/// @param _tokenId The NFT to transfer
	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

	/// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
	///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
	///  THEY MAY BE PERMANENTLY LOST
	/// @dev Throws unless `msg.sender` is the current owner, an authorized
	///  operator, or the approved address for this NFT. Throws if `_from` is
	///  not the current owner. Throws if `_to` is the zero address. Throws if
	///  `_tokenId` is not a valid NFT.
	/// @param _from The current owner of the NFT
	/// @param _to The new owner
	/// @param _tokenId The NFT to transfer
	function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

	/// @notice Set or reaffirm the approved address for an NFT
	/// @dev The zero address indicates there is no approved address.
	/// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
	///  operator of the current owner.
	/// @param _approved The new approved NFT controller
	/// @param _tokenId The NFT to approve
	function approve(address _approved, uint256 _tokenId) external payable;

	/// @notice Enable or disable approval for a third party ("operator") to manage
	///  all of `msg.sender`'s assets.
	/// @dev Emits the ApprovalForAll event. The contract MUST allow
	///  multiple operators per owner.
	/// @param _operator Address to add to the set of authorized operators.
	/// @param _approved True if the operator is approved, false to revoke approval
	function setApprovalForAll(address _operator, bool _approved) external;

	/// @notice Get the approved address for a single NFT
	/// @dev Throws if `_tokenId` is not a valid NFT
	/// @param _tokenId The NFT to find the approved address for
	/// @return The approved address for this NFT, or the zero address if there is none
	function getApproved(uint256 _tokenId) external view returns (address);

	/// @notice Query if an address is an authorized operator for another address
	/// @param _owner The address that owns the NFTs
	/// @param _operator The address that acts on behalf of the owner
	/// @return True if `_operator` is an approved operator for `_owner`, false otherwise
	function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC721TokenReceiver {
	/// @notice Handle the receipt of an NFT
	/// @dev The ERC721 smart contract calls this function on the
	/// recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
	/// of other than the magic value MUST result in the transaction being reverted.
	/// @notice The contract address is always the message sender.
	/// @param _operator The address which called `safeTransferFrom` function
	/// @param _from The address which previously owned the token
	/// @param _tokenId The NFT identifier which is being transferred
	/// @param _data Additional data with no specified format
	/// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
	/// unless throwing
	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract Loot is ERC721
{
	mapping(uint256 => address) _object_ownership;
	mapping(address => uint256[]) _loot;
	mapping(address => uint256) _loot_nb;

	mapping(uint256 => address) _approved_for_object;
	mapping(address => mapping(address => bool)) _approved_for_all;

	uint256 constant INVALID_TOKEN = ~uint256(0);
	uint256 constant INVALID_INDEX = ~uint256(0);

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

	address payable private _creator;

	constructor() public
	{
		_creator = msg.sender;
	}

	function loot_index(uint256 token) external view returns(uint index)
	{
		uint256[] memory array = _loot[msg.sender];

		for(uint i; i < array.length; ++i)
		{
			if (array[i] == token)
			{
				return i;
			}
		}

		return INVALID_TOKEN;
	}

	function tokenize(Object calldata loot) external pure returns(uint256 token)
	{
		require(loot._occurence < MAX_OCCURENCE);
		require(loot._type < MAX_TYPE);
		require(loot._number < MAX_NUMBER);
		return _tokenize(loot);
	}

	function getOccurence(uint256 token) public pure returns(uint256)
	{
		uint256 occurence = token / 1000;
		require(occurence < MAX_OCCURENCE);
		return occurence;
	}

	function getType(uint256 token) public pure returns(uint256)
	{
		uint256 type_ = (token / 100) % 10;
		require(type_ < MAX_TYPE);
		return type_;
	}

	function getNumber(uint256 token) public pure returns(uint256)
	{
		return token % 100;
	}

	function objectify(uint256 token) external pure returns(Object memory)
	{
		Object memory loot;
		loot._occurence = uint8(getOccurence(token));
		loot._type = uint8(getType(token));
		loot._number = uint8(getNumber(token));
		return loot;
	}

	uint256 private constant JUST_A_PRIME = 58924111272703312024330679540447756419615700313505690924028338601366555452541;

	function dig(uint8 max_tries) external payable returns(uint256 token)
	{
		require(msg.value >= 100 finney, "402 payment required");

		uint seed = JUST_A_PRIME * uint256(blockhash(block.number-1));

		for (uint8 tries = 0; tries < max_tries; ++tries)
		{
			uint256 token_ = _object_from_random(seed);

			if ( false == _object_exists(token_) )
			{
				_creator.transfer(msg.value);
				_receive_token(msg.sender, token_);
				emit Transfer(address(0), msg.sender, token_);
				return token_;
			}

			seed *= JUST_A_PRIME;
		}

		// refund sender
		msg.sender.transfer(msg.value);
		return INVALID_TOKEN;
	}

	function use(uint256 token) external returns(uint256 usage)
	{
		require(_object_ownership[token] == msg.sender, "401 unauthorized");

		uint usage_ = _randomize(JUST_A_PRIME * uint256(blockhash(block.number-1))) % 11;

		if (usage_ == 0)
		{
			_object_ownership[token] = address(0);
			_approved_for_object[token] = address(0);
			emit Transfer(msg.sender, address(0), token);
			// _loot is not updated because it'd necessitate a a loop
			_loot_nb[msg.sender] -= 1;
		}

		return usage_;
	}

	function balanceOf(address _owner) external view returns (uint256)
	{
		require(_owner != address(0));
		return _loot_nb[_owner];
	}

	function ownerOf(uint256 _tokenId) external view returns (address)
	{
		address owner = _object_ownership[_tokenId];
		require(owner != address(0));
		return owner;
	}

	bytes4 private ERC721_RECEIVED = ERC721TokenReceiver(0).onERC721Received.selector;

	function _transferFrom(address _from, address _to, uint256 _tokenId) internal
	{
		require(_object_ownership[_tokenId] == _from && _from != address(0));
		require(_sender_has_approval_of(_from, _tokenId));
		_receive_token(_to, _tokenId);
		_approved_for_object[_tokenId] = address(0);
		_loot_nb[_from] -= 1;
		emit Transfer(_from, _to, _tokenId);
	}

	function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) internal
	{
		require(_to != address(0));
		_transferFrom(_from, _to, _tokenId);

		uint size;
		assembly { size := extcodesize(_to) }

		if (size > 0)
		{
			require(ERC721_RECEIVED == ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data));
		}
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable
	{
		_creator.transfer(msg.value);
		_safeTransferFrom(_from, _to, _tokenId, data);
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable
	{
		_creator.transfer(msg.value);
		_safeTransferFrom(_from, _to, _tokenId, '');
	}

	function transferFrom(address _from, address _to, uint256 _tokenId) external payable
	{
		_creator.transfer(msg.value);
		_transferFrom(_from, _to, _tokenId);
	}

	function approve(address _approved, uint256 _tokenId) external payable
	{
		_creator.transfer(msg.value);
		address owner = _object_ownership[_tokenId];
		require(owner != address(0));
		require(_sender_has_approval_of(owner, _tokenId));
		_approved_for_object[_tokenId] = _approved;
		emit Approval(msg.sender, _approved, _tokenId);
	}

	function setApprovalForAll(address _operator, bool _approved) external
	{
		_approved_for_all[msg.sender][_operator] = _approved;
		emit ApprovalForAll(msg.sender, _operator, _approved);
	}

	function getApproved(uint256 _tokenId) external view returns (address)
	{
		require (_object_exists(_tokenId));	
		return _approved_for_object[_tokenId];
	}

	function isApprovedForAll(address _owner, address _operator) external view returns (bool)
	{
		return _approved_for_all[_owner][_operator];
	}

	/*
	 * Internal methods
	 */

	function _sender_has_approval_of(address someguy, uint256 token) internal view returns(bool yay_or_nay)
	{
		return msg.sender == someguy
			||	_approved_for_object[token] == msg.sender
			||	_approved_for_all[someguy][msg.sender];
	}

	function _object_exists(uint256 token) internal view returns(bool)
	{
		return _object_ownership[token] != address(0);
	}

	function _randomize(uint256 seed) internal pure returns(uint256 rand)
	{
		return uint(keccak256(abi.encodePacked(seed)));
	}

	uint private constant OCCURENCE_MASK = 0xFF;
	uint private constant TYPE_MASK = 0x03;
	uint private constant NUMBER_MASK = 0xFFFF;

	function _tokenize(Object memory loot) public pure returns(uint256 token)
	{
		return loot._occurence*OCCURENCE_SHIFT + loot._type*TYPE_SHIFT + loot._number;
	}

	function _object_from_random(uint256 rand) internal pure returns(uint256 token)
	{
		Object memory loot;
		loot._number = uint8((rand & NUMBER_MASK) % 100);
		uint occurence = (rand / 2**16) & OCCURENCE_MASK;

		if (occurence < 170)
		{
			loot._occurence = OCCURENCE_DIVINE;
		}
		else if (occurence < 240)
		{
			loot._occurence = OCCURENCE_RARE;
		}
		else
		{
			loot._occurence = OCCURENCE_COMMON;
		}

		loot._type = uint8((rand / 2**24) & TYPE_MASK);

		return _tokenize(loot);
	}

	function _receive_token(address owner, uint256 token) internal
	{
		_object_ownership[token] = owner;
		_loot[owner].push(token);
		_loot_nb[owner] += 1;
	}
}