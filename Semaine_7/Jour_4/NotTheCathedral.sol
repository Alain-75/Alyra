pragma solidity ^0.5.4;
// pragma experimental ABIEncoderV2;

contract NotTheCathedral
{
	struct Auction
	{
		uint256 _token;
		address _ERC721_minter;
		address _owner;
		uint256 _auction_end;
		address _best_bidder;
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
	mapping(bytes32 => Auction) _auctions;
	// minter => token => hash
	mapping(address => mapping(uint256 => bytes32)) _by_hash_and_minter;

	function auction(address minter, uint256 token, uint256 time_in_s, uint256 starting_price) public
	{
		
	}
}