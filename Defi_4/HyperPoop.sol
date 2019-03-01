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

contract TheHyperPoop is ERC721
{
	mapping(uint256 => address) public _poop_ownership;
	mapping(address => uint256[]) public _my_poop;
	mapping(address => uint256) public _how_much_poop_i_own;

	mapping(uint256 => address) private _approved_for_this_poop;
	mapping(address => mapping(address => bool)) private _approved_for_all_my_poop;

	enum Fluidity
	{
		DIARRHEIC,
		GOOEY,
		FIRM,
		TOO_HARD_OUCH
	}

	enum Consistency
	{
		EQUAL,
		BLOODY,
		CRUNCHY,
		EXTRA_CRUNCHY
	}

	enum Color
	{
		GREEN,
		BROWN,
		YELLOW,
		MOSTLY_GREY
	}

	enum Smell
	{
		BAD,
		WORSE,
		WORST,
		CHEMICAL_WARFARE
	}

	enum Shape
	{
		PEARLS,
		SAUSAGE_STREAM,
		PERFECT_SAUSAGE,
		PIPE_CLOGGER
	}

	struct Poop
	{
		Fluidity _fluidity;
		Consistency _consistency;
		Color _color;
		Smell _smell;
		Shape _shape;
		uint8 _remaining_quantity;
	}

	struct SomePoop
	{
		uint256 _origin;
		uint8 _quantity;
	}

	struct ThrownPoop
	{
		SomePoop[] _poops;
		address _pooper;
		uint256 _value;
		string _location;
		bool _ready_to_eat;
	}

	mapping(uint256 => Poop) _poop_registry;
	mapping(address => SomePoop[]) _mixtures;
	mapping(address => ThrownPoop[]) _thrown_poop;

	address payable private _ether_flush;

	constructor() public
	{
		_ether_flush = msg.sender;
	}

	/* EXTERNAL METHODS */

	function where_s_my_poop(uint256 index) external view returns(bool still_here)
	{
		uint256[] memory poops = _my_poop[msg.sender];
		return index < poops.length && _poop_ownership[poops[index]] == msg.sender;
	}

	uint256 private constant JUST_A_PRIME = 58924111272703312024330679540447756419615700313505690924028338601366555452541;

	function take_a_dump() external payable returns(uint256 token)
	{
		require(msg.value >= 100000000000 wei, "402 payment required");

		uint poop = uint(keccak256(abi.encodePacked(JUST_A_PRIME * uint256(blockhash(block.number-1)))));
		require(false == _poop_exists(poop), "302 constipated");

		_receive_poop(msg.sender, poop);
		_poop_registry[poop] = _token_to_poop(poop);

		emit Transfer(address(0), msg.sender, poop);
		_ether_flush.transfer(msg.value);

		return poop;
	}

	function mix(uint256 token, uint8 quantity) external
	{
		require(_poop_ownership[token] == msg.sender, "401 unauthorized");
		require(_poop_registry[token]._remaining_quantity >= quantity, "40poop not enough poop failure");

		_poop_registry[token]._remaining_quantity -= quantity;

		SomePoop[] storage mixed_poop = _mixtures[msg.sender];
		SomePoop storage poop = mixed_poop[mixed_poop.length++];
		poop._origin = token;
		poop._quantity = quantity;

		if (_poop_registry[token]._remaining_quantity == 0)
		{
			_poop_ownership[token] = address(0);
			emit Transfer(msg.sender, address(0), token);
		}
	}

	function throw_shit(address payable on, string calldata at) external payable
	{
		require(msg.value >= 1 wei, "402 payment required");
		require(_mixtures[msg.sender].length > 0, "404 poop does not exist");

		ThrownPoop[] storage thrown_poop = _thrown_poop[on];
		ThrownPoop memory mixture = thrown_poop[thrown_poop.length++];
		mixture._poops = _mixtures[msg.sender];
		_mixtures[msg.sender].length = 0;
		mixture._pooper = msg.sender;
		mixture._value = msg.value;
		mixture._location = at;
		mixture._ready_to_eat = true;
	}

	function eat_shit(uint256 poop_index) external
	{
		ThrownPoop storage YUMMY = _thrown_poop[msg.sender][poop_index];
		require(YUMMY._ready_to_eat, "404 no more shit to eat here, people, please move along");
		YUMMY._ready_to_eat = false;
		msg.sender.transfer(YUMMY._value);
	}

	function balanceOf(address _owner) external view returns (uint256)
	{
		require(_owner != address(0));
		return _how_much_poop_i_own[_owner];
	}

	function ownerOf(uint256 _tokenId) external view returns (address)
	{
		address owner = _poop_ownership[_tokenId];
		require(owner != address(0));
		return owner;
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable
	{
		_ether_flush.transfer(msg.value);
		_safeTransferFrom(_from, _to, _tokenId, data);
	}

	function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable
	{
		_ether_flush.transfer(msg.value);
		_safeTransferFrom(_from, _to, _tokenId, '');
	}

	function transferFrom(address _from, address _to, uint256 _tokenId) external payable
	{
		_ether_flush.transfer(msg.value);
		_transferFrom(_from, _to, _tokenId);
	}

	function approve(address _approved, uint256 _tokenId) external payable
	{
		_ether_flush.transfer(msg.value);
		address owner = _poop_ownership[_tokenId];
		require(owner != address(0));
		require(_sender_has_approval_of(owner, _tokenId));
		_approved_for_this_poop[_tokenId] = _approved;
		emit Approval(msg.sender, _approved, _tokenId);
	}

	function setApprovalForAll(address _operator, bool _approved) external
	{
		_approved_for_all_my_poop[msg.sender][_operator] = _approved;
		emit ApprovalForAll(msg.sender, _operator, _approved);
	}

	function getApproved(uint256 _tokenId) external view returns (address)
	{
		require (_poop_exists(_tokenId));	
		return _approved_for_this_poop[_tokenId];
	}

	function isApprovedForAll(address _owner, address _operator) external view returns (bool)
	{
		return _approved_for_all_my_poop[_owner][_operator];
	}

	/* INTERNAL METHODS */

	function _poop_exists(uint256 token) internal view returns(bool)
	{
		return _poop_ownership[token] != address(0);
	}

	function _receive_poop(address owner, uint256 token) internal
	{
		_poop_ownership[token] = owner;
		_my_poop[owner].push(token);
		_how_much_poop_i_own[owner] += 1;
	}

	uint constant POOPY_MASK = 0x03;
	uint constant POOP_SIZE_MASK = 0x7F;

	function _token_to_poop(uint256 token) internal pure returns(Poop memory freshly_backed_poop)
	{
		Poop memory poop;
		poop._fluidity = Fluidity(token & POOPY_MASK);
		token /= 8;
		poop._consistency = Consistency(token & POOPY_MASK);
		token /= 8;
		poop._color = Color(token & POOPY_MASK);
		token /= 8;
		poop._smell = Smell(token & POOPY_MASK);
		token /= 8;
		poop._shape = Shape(token & POOPY_MASK);
		token /= 8;
		poop._remaining_quantity = 1 + uint8(token & POOP_SIZE_MASK);
		return poop;
	}

	function _sender_has_approval_of(address someguy, uint256 token) internal view returns(bool yay_or_nay)
	{
		return msg.sender == someguy
			||	_approved_for_this_poop[token] == msg.sender
			||	_approved_for_all_my_poop[someguy][msg.sender];
	}

	bytes4 private ERC721_RECEIVED = ERC721TokenReceiver(0).onERC721Received.selector;

	function _transferFrom(address _from, address _to, uint256 _tokenId) internal
	{
		require(_poop_ownership[_tokenId] == _from && _from != address(0));
		require(_sender_has_approval_of(_from, _tokenId));
		_receive_poop(_to, _tokenId);
		_approved_for_this_poop[_tokenId] = address(0);
		_how_much_poop_i_own[_from] -= 1;
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
}