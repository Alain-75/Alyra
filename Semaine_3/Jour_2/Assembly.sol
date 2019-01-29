//Write your own contracts here. Currently compiles using solc v0.4.15+commit.bbb8e64f.
pragma solidity ^0.4.25;

contract Crew
{
  uint constant VOTE_DELAY_SECONDS = 60*60*24*7; // vote stays open for a week at most
  address owner;
  string name;
  address[] members;
  mapping(string => VoteTally) proposals;

  constructor(string memory crew_name) public
  {
    name = crew_name;
    owner = msg.sender;
  }

  struct VoteTally
  {
    uint start_time;
    address[] votes_for;
    address[] votes_against;
    bool initialized;
    bool closed;
  }

  function __is_closed(VoteTally storage t) internal view returns (bool)
  {
    return t.closed || __total(t) == members.length || now - t.start_time > VOTE_DELAY_SECONDS;
  }

  function __delete_address_from_array(address[] storage array, uint index) internal
  {
    delete array[index];

    for(uint i = index; i < array.length-1; ++i)
    {
      array[i] = array[i+1];
    }
  }

  function cancel_vote(string memory proposal) public
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t) == false, "Vote is closed.");

    for (uint i = 0; i < t.votes_for.length; ++i)
    {
      if (t.votes_for[i] == msg.sender)
      {
        __delete_address_from_array(t.votes_for, i);
        break;
      }
    }

    for (i = 0; i < t.votes_against.length; ++i)
    {
      if (t.votes_against[i] == msg.sender)
      {
        __delete_address_from_array(t.votes_against, i);
        break;
      }
    }
  }

  function __has_voted(VoteTally storage t) internal constant returns(bool)
  {
    for (uint i = 0; i < t.votes_for.length; i++)
    {
      if (t.votes_for[i] == msg.sender)
      {
        return true;
      }
    }

    for (i = 0; i < t.votes_against.length; i++)
    {
      if (t.votes_against[i] == msg.sender)
      {
        return true;
      }
    }

    return false;
  }

  function __vote_for(VoteTally storage t) internal
  {
    if (__has_voted(t) == false)
    {
      t.votes_for.push(msg.sender);
    }
  }

  function __vote_against(VoteTally storage t) internal
  {
    if(__has_voted(t) == false)
    {
      t.votes_against.push(msg.sender);
    }
  }

  function __total(VoteTally storage t) internal view returns (uint)
  {
    return t.votes_for.length + t.votes_against.length;
  }

  function __tally(VoteTally storage t) internal view returns (bool)
  {
    return t.votes_for.length > t.votes_against.length;
  }

  function join() public
  {
    members.push(msg.sender);
  }

  function is_crew(address guy) public constant returns (bool)
  {
    for (uint i = 0; i < members.length; i++)
    {
      if (members[i] == guy)
      {
        return true;
      }
    }

    return false;
  }

  function submit_proposal(string memory proposal) public
  {
    require(is_crew(msg.sender), "Sender not allowed to submit proposals.");
    require(proposals[proposal].initialized == false, "Proposal does not exist.");
  
    proposals[proposal].initialized = true;
  }

  function vote(string memory proposal, bool for_or_against) public
  {
    VoteTally storage t = proposals[proposal];

    require(is_crew(msg.sender), "Sender not allowed to vote.");
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t) == false, "Vote is closed.");

    if (for_or_against)
    {
      __vote_for(t);
    }
    else
    {
      __vote_against(t);
    }
  }

  function has_voted(string memory proposal) internal constant returns(bool)
  {
    return __has_voted(proposals[proposal]);
  }

  function has_quorum(string memory proposal) public constant returns (bool)
  {
    require(proposals[proposal].initialized, "Proposal does not exist.");
    return __total(proposals[proposal]) > 2*members.length/3;
  }

  function is_closed(string memory proposal) public constant returns (bool)
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    return __is_closed(t);
  }

  function close_vote(string memory proposal) public
  {
    VoteTally storage t = proposals[proposal];
    require(owner == msg.sender, "Only owner can close a vote.");
    require(t.initialized, "Proposal does not exist.");
    require(has_quorum(proposal), "Cannot close vote before reaching quorum.");
    t.closed = true;
  }

  function is_accepted(string memory proposal) public constant returns (bool)
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t), "Vote is not closed yet.");
    return __tally(proposals[proposal]);
  }

  function cancel_proposal(string memory proposal) public
  {
    VoteTally storage t = proposals[proposal];
    require(owner == msg.sender, "Only owner can cancel a proposal.");
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t) == false, "Vote is closed.");

    t.initialized = false;
    delete t.votes_for;
    delete t.votes_against;
  }
}
