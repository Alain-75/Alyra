pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SharedVenture
{
	using SafeMath for uint256;
    
	/*
	 * ~~~~~~~~~~~~~~~~ PUBLIC INTERFACE
	 */
	constructor(uint liquidation_date, uint max_expense_per_period) public
	{
		_shareholders.push(msg.sender);
		_shares[msg.sender] = NB_SHARES;
		_liquidation_date = liquidation_date;
		_liquidation_started = false;
		_expenses = 0;
		// Spending periods are in increments of 1 day from contract deployment.
		_current_spending_window_start = now;
		_expenses_over_current_window = 0;
		_max_expense_per_period = max_expense_per_period;
	}

	/* MODIFIERS */

	modifier verify_sender_is_shareholder
	{
		require(is_shareholder(msg.sender), "Only an shareholder can accomplish this action.");
		_;
	}

	/* VIEW METHODS */

	function is_shareholder(address somebody) public view returns(bool)
	{
		return _find_shareholder(somebody) != _shareholders.length;
	}

	/* WRITE METHODS */

	function grant_shares(address grantee, uint nb_shares) public
	{
		uint sender_index = _find_shareholder(msg.sender);

		require(sender_index != _shareholders.length, "Only an shareholder can grant shares.");
		require(nb_shares > 0, "Must grant at least one share.");
		require(_shares[msg.sender] >= nb_shares, "Not enough remaining shares for grant.");

		_shares[msg.sender] -= nb_shares; // already checked for underflow
		_shares[grantee] += nb_shares; // overflow not possible, since total share limit is NB_SHARES

		if (false == is_shareholder(grantee))
		{
			_shareholders.push(grantee);
		}

		if (0 == _shares[msg.sender])
		{
			_remove_shareholder(sender_index);
		}
	}

	function spend_budget(address payable recipient, uint amount) public verify_sender_is_shareholder
	{
		require(false == _liquidation_started, "Cannot spend during liquidation.");

		bool period_over = now > _current_spending_window_start.add(BUDGET_PERIOD);

		require(
				period_over
			||	_expenses_over_current_window.add(amount) < _max_expense_per_period
			,	"Budget is lacking for today."
			);
		require(recipient != address(0), "Null recipient address.");
		require(amount > 0);

		_expenses = _expenses.add(amount);
		recipient.transfer(amount);

		if (period_over)
		{
			// reset spending window
			_current_spending_window_start = now;
			_expenses_over_current_window = amount;
		}
		else
		{
			_expenses_over_current_window = _expenses_over_current_window.add(amount);	
		}
	}

	function liquidate_shares() public verify_sender_is_shareholder
	{
		require(now > _liquidation_date, "Be patient, payday is not just yet.");
		require(false == _has_liquidated[msg.sender], "Get lost, you greedy capitalist!");

		if (false == _liquidation_started)
		{
			_liquidation_started = true;
			_liquidation_balance = address(this).balance;
		}

		_has_liquidated[msg.sender] = true;
		msg.sender.transfer( (_liquidation_balance.mul(_shares[msg.sender])).div(NB_SHARES) );

		if (_is_liquidation_over())
		{
			selfdestruct(msg.sender);
		}
	}

	/*
	 * ~~~~~~~~~~~~~~~~ INTERNAL METHODS
	 */
	function _find_shareholder(address somebody) internal view returns (uint array_index)
	{
		for (uint i = 0; i < _shareholders.length; i++)
		{
			if (somebody == _shareholders[i])
			{
				return i;
			}
		}

		return _shareholders.length;
	}

	function _remove_shareholder(uint index) internal
	{
		delete _shareholders[index];

		for (uint i = index; i < _shareholders.length - 1; i++)
		{
			_shareholders[i] = _shareholders[i+1];
			delete _shareholders[i+1];
		}
	}

	function _is_liquidation_over() internal view returns(bool)
	{
		for (uint i = 0; i < _shareholders.length; i++)
		{
			if (false == _has_liquidated[_shareholders[i]])
			{
				return false;
			}
		}

		return true;
	}

	/*
	 * ~~~~~~~~~~~~~~~~ DATA MEMBERS
	 */
	uint constant NB_SHARES = 100;
	uint constant BUDGET_PERIOD = 1 days;
	address[] public _shareholders;
	mapping(address => uint) internal _shares;
	mapping(address => bool) internal _has_liquidated;
	uint private _expenses;
	uint public _liquidation_date;
	bool public _liquidation_started;
	uint public _liquidation_balance;
	uint private _current_spending_window_start;
	uint private _expenses_over_current_window;
	uint private _max_expense_per_period;
}

contract Hellfest is SharedVenture
{
	/*
	 * ~~~~~~~~~~~~~~~~ PUBLIC INTERFACE
	 */

	/* WRITE METHODS */

	constructor(
			uint nb_tickets
		,	uint ticket_cost
		,	uint festival_start
		,	uint festival_end
		,	uint max_expense_per_period
		)
		SharedVenture(festival_end + 2 weeks, max_expense_per_period) public
	{
		require(
				_festival_start > now
			&&	_festival_end > _festival_start + 1 days
			,	"You have time management issues."
			);
		require(nb_tickets > 0 && ticket_cost > 0, "Dont be an idiot, we be makin C.R.E.A.M. here.");
		_nb_tickets = nb_tickets;
		_ticket_cost = ticket_cost;
		_sold_tickets = 0;
		_festival_start = festival_start;
		_festival_end = festival_end;
	}

	function () external payable {}

	modifier verify_sender_is_metalhead
	{
		require(_is_metalhead(msg.sender), "Only metalheads can do this.");
		_;
	}

	function buy_ticket() public payable
	{
		require(now <= _festival_end, "Hellfest is over.");
		require(msg.value > _ticket_cost, "You must buy at least one ticket.");
		require(msg.value / _ticket_cost <= _nb_tickets - _sold_tickets, "Not enough tickets left.");

		uint previous_balance = _metalheads[msg.sender];
		uint previous_tickets = previous_balance.div(_ticket_cost);
		uint current_balance = previous_balance.add(msg.value);

		// In case client wants to buy more than one ticket,
		// we record how much they've payed until now.
		_metalheads[msg.sender] = current_balance;

		// since ticket_cost is at least one, current_balance is
		// guaranteed to overflow before _sold_tickets
		uint current_tickets = current_balance.div(_ticket_cost);
		_sold_tickets += current_tickets - previous_tickets;
	}

	function has_tickets(address someone) public view returns(uint number_of_tickets)
	{
		return _metalheads[someone] / _ticket_cost;
	}

	function sponsorize(string memory sponsor_name) public payable
	{
		require(msg.value > 30 ether, "You need to pay at least 30 ethers to become a sponsor");
		_sponsors.push(sponsor_name);
	}

	function buy_lottery_ticket(uint festival_day, uint8 ticket_number) public payable verify_sender_is_metalhead()
	{
		// festival_day must be between 1 and (_festival_end - _festival_start) / 1 days included
		// (_festival_end - _festival_start) has already been checked for underflows.
		require(
				festival_day > 0
			&&	((festival_day - 1).mul(1 days)) <= (_festival_end - _festival_start)
			,	"Lottery tickets are available only on festival days."
			);

		require(msg.value >= LOTTERY_TICKET_PRICE, "Not paying enough for a lottery ticket.");
		require(_lottery_tickets[msg.sender][festival_day] == 0,
			"You already have a ticket for lottery on that day.");
		require(ticket_number != 0, "Your ticket number cannot be 0");

		_lottery_tickets[msg.sender][festival_day] = ticket_number;
	}

	function has_won_lottery(uint festival_day) public view verify_sender_is_metalhead returns(bool has_won)
	{
		return _lottery_results[festival_day] == _lottery_tickets[msg.sender][festival_day];
	}

	function recover_lottery_gain(uint festival_day) public verify_sender_is_metalhead
	{
		require(has_won_lottery(festival_day), "You have not won on that day, or already got your gain.");
		require(
				((festival_day - 1).mul(1 days)).add(_festival_start).add(LOTTERY_RECOVER_DELAY) > now
			,	"You have to wait a little more to recover your gain."
			);

		_lottery_tickets[msg.sender][festival_day] = 0;
		msg.sender.transfer(LOTTERY_GAIN);
	}

	/*
	 * ~~~~~~~~~~~~~~~~ INTERNAL METHODS
	 */

	function _is_metalhead(address someone) internal view returns(bool)
	{
		return _metalheads[someone] > 0;
	}

	function _generate_lottery_ticket() internal view returns(uint8)
	{
		uint seed = uint(blockhash(block.number-1));

		while (uint8(seed) == 0)
		{
			seed *= 6767665691983247; // here, we don't care about overflow
			seed = uint(keccak256(abi.encodePacked(seed)));
		}

		return uint8(seed);
	}

	/*
	 * ~~~~~~~~~~~~~~~~ DATA MEMBERS
	 */

	uint constant LOTTERY_TICKET_PRICE = 100 finney;
	uint constant LOTTERY_GAIN = 1 ether; // metalheads are too drunk to understand probability
	uint constant LOTTERY_RECOVER_DELAY = 2 days;

	uint public _nb_tickets;
	uint public _ticket_cost;
	uint public _sold_tickets;
	uint public _festival_start;
	uint public _festival_end;
	string[] public _sponsors;

	mapping(address => uint) internal _metalheads;
	mapping(address => mapping(uint => uint8)) private _lottery_tickets;
	mapping(uint => uint8) private _lottery_results;
}
