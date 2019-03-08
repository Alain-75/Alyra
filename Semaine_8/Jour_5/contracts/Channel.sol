pragma solidity ^0.5.5;

import 'github.com/OpenZeppelin/openzeppelin-solidity/contracts/cryptography/ECDSA.sol';

contract Channel
{
	event Active(uint initiator_balance, uint counterpart_balance);
	event Closing(uint last_nonce, uint initiator_balance, uint counterpart_balance);

	enum State
	{
		WAITING, ACTIVE, CLOSING, CLOSED
	}

	address public _initiator;
	address public _counterpart;
	uint public _amount;
	State public _state;
	uint public _closing_block; 
	uint public _last_nonce;
	uint public _initiator_balance;
	uint public _counterpart_balance;
	uint constant NB_BLOCK_BEFORE_RECOVER = 24; // more or less six minutes
	uint constant NB_BLOCK_BEFORE_LIQUIDATE = NB_BLOCK_BEFORE_RECOVER * 10 * 24 * 30; // somewhat akin to a month
	uint constant MIN_CHANNEL_AMOUNT = 1000 wei;

	constructor(address initiator, address counterpart) public payable
	{
		require(msg.value >= MIN_CHANNEL_AMOUNT);
		_state = State.WAITING;
		_amount = msg.value;
		_initiator = initiator;
		_counterpart = counterpart;
		_initiator_balance = msg.value;
	}

	function _on_cancel() internal
	{
		_closing_block = block.number;
		_state = State.CLOSING;
		emit Closing(_last_nonce, _initiator_balance, _counterpart_balance);
	}

	function stop_wait() external
	{
		require(msg.sender == _initiator && _state == State.WAITING);
		_on_cancel();
	}

	function counterpart_join() external payable
	{
		require(	msg.sender == _counterpart
				&&	_state == State.WAITING
				&&	msg.value >= _amount
				);
		_state = State.ACTIVE;
		_counterpart_balance += msg.value;
		emit Active(_initiator_balance, _counterpart_balance);
	}

	function initiator_fund() external payable
	{
		require(_state == State.ACTIVE && msg.sender == _initiator && msg.value >= _amount);
		_initiator_balance += msg.value;
	}

	function counterpart_fund() external payable
	{
		require(_state == State.ACTIVE && msg.sender == _counterpart && msg.value >= _amount);
		_counterpart_balance += msg.value;
	}

	function message(uint nonce, uint initiator_balance, uint counterpart_balance) public view returns (bytes32 mess)
	{
		require(initiator_balance + counterpart_balance == _initiator_balance + _counterpart_balance);
		return keccak256(abi.encodePacked(nonce, initiator_balance, counterpart_balance));
	}

	function submit_balance(uint nonce, uint initiator_balance, uint counterpart_balance, bytes calldata opposite_signature) external
	{
		require(nonce > _last_nonce);

		address opposite_addr = ECDSA.recover(message(nonce, initiator_balance, counterpart_balance), opposite_signature);

		require(	(msg.sender == _initiator && opposite_addr == _counterpart)
				||	(msg.sender == _counterpart && opposite_addr == _initiator)
				);

		if ( _state == State.ACTIVE )
		{
			_closing_block = block.number;
			_state = State.CLOSING;
		}
		else if ( _state != State.CLOSING )
		{
			require(false);
		}

		_initiator_balance = initiator_balance;
		_counterpart_balance = counterpart_balance;
		_last_nonce = nonce;
		emit Closing(_last_nonce, _initiator_balance, _counterpart_balance);
	}

	function cancel() external
	{
		require(_state == State.ACTIVE && msg.sender == _initiator || msg.sender == _counterpart);
		_on_cancel();
	}

	function recover() external
	{
		require(_state == State.CLOSING && block.number > _closing_block + NB_BLOCK_BEFORE_RECOVER);

		if ( msg.sender == _initiator && _initiator_balance > 0 )
		{
			uint balance = _initiator_balance;
			_initiator_balance = 0;
			msg.sender.transfer(balance);
		}
		if ( msg.sender == _counterpart && _counterpart_balance > 0 )
		{
			uint balance = _counterpart_balance;
			_counterpart_balance = 0;
			msg.sender.transfer(balance);
		}

		if (_initiator_balance == 0 && _counterpart_balance == 0)
		{
			_state == State.CLOSED;
		}
	}

	function liquidate() external
	{
		require(	_state == State.CLOSED
				||	block.number > _closing_block + NB_BLOCK_BEFORE_LIQUIDATE);
		selfdestruct(msg.sender);
	}
}

contract Channels
{
	Channel[] public _channels;

	function add_channel(address counterpart) external payable returns(address channel)
	{
		_channels.push((new Channel).value(msg.value)(msg.sender, counterpart));
		return address(_channels[_channels.length-1]);
	}
}
