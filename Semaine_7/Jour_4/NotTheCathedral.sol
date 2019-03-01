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

contract NotTheCathedral
{
	uint256 constant MIN_BID_SPREAD = 1 szabo;

	event AuctionStarted(bytes32 indexed hash, address minter, uint256 token, uint256 end_time);
	event Bid(bytes32 indexed hash, uint256 value);
	event AuctionRecovered(bytes32 indexed hash);
	
	struct Auction
	{
		uint256 _token;
		address _ERC721_minter;
		address payable _owner;
		uint256 _auction_end;
		address payable _best_bidder;
		uint256 _best_bid;
	}

	function auction_id(Auction memory auction) public pure returns(bytes32 hash)
	{
		return keccak256(abi.encodePacked(
				auction._token
			,	auction._owner
			,	auction._auction_end
			));
	}

	// hash => auction
	mapping(bytes32 => Auction) public _auctions;
	// minter => token => hash
	mapping(address => mapping(uint256 => bytes32)) public _hash_by_minter_and_token;

	mapping(address => uint256) private _waiting_funds;

	function initiate_auction(address minter, uint256 token, uint256 time_in_s, uint256 starting_price) external
	{
		require(address(this) == ERC721(minter).getApproved(token));

		Auction memory auction;
		auction._token = token;
		auction._ERC721_minter = minter;
		auction._owner = msg.sender;
		auction._auction_end = now + time_in_s;
		auction._best_bid = starting_price;
		bytes32 hash = auction_id(auction);
		_auctions[hash] = auction;
		_hash_by_minter_and_token[minter][token] = hash;
		emit AuctionStarted(hash, minter, token, auction._auction_end);
	}

	function bid(bytes32 hash) external payable
	{
		Auction storage auction = _auctions[hash];
		require(auction._token != 0);
		require(auction._auction_end < now);
		require(auction._best_bid + MIN_BID_SPREAD <= msg.value);

		if (auction._best_bidder != address(0))
		{
			_waiting_funds[auction._best_bidder] = auction._best_bid;
		}

		auction._best_bid = msg.value;
		auction._best_bidder = msg.sender;

		emit Bid(hash, msg.value);
	}

	function recover_funds() external
	{
		uint256 value = _waiting_funds[msg.sender];

		if (value > 0)
		{
			msg.sender.transfer(value);
			_waiting_funds[msg.sender] = 0;
		}
	}

	function recover_auction(bytes32 hash) external returns(bool recovery_approved)
	{
		Auction storage auction = _auctions[hash];
		require(auction._auction_end >= now);
		require(auction._best_bidder == msg.sender);

		emit AuctionRecovered(hash);

		ERC721 minter = ERC721(auction._ERC721_minter);

		if ( auction._token != 0 && address(this) == minter.getApproved(auction._token) )
		{
			minter.safeTransferFrom(auction._owner, msg.sender, auction._token);
			auction._token = 0;
			return true;
		}

		_waiting_funds[msg.sender] = auction._best_bid;
		auction._best_bidder = address(0);
		return false;
	}

	function _is_auction_recovered(Auction memory auction) internal pure returns(bool)
	{
		return	( auction._token == 0 && auction._best_bidder != address(0) )
			||	( auction._token != 0 && auction._best_bidder == address(0) );
	}

	function is_auction_recovered(bytes32 hash) external view returns(bool)
	{
		return _is_auction_recovered(_auctions[hash]);
	}

	function end_auction(bytes32 hash) external returns(bool funds_available)
	{
		Auction storage auction = _auctions[hash];
		require(_is_auction_recovered(auction));
		require(auction._auction_end >= now);
		require(auction._owner == msg.sender);

		auction._owner = address(0);

		if ( auction._token == 0 )
		{
			_waiting_funds[msg.sender] = auction._best_bid;
			return true;
		}

		auction._token = 0;
		return false;
	}

	function is_auction_ended(bytes32 hash) external view returns (bool)
	{
		return _auctions[hash]._owner == address(0);
	}
}