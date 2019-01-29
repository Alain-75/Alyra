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
    return t.closed || now - t.start_time > VOTE_DELAY_SECONDS;
  }

  function __delete_sender_from_array(address[] storage array) internal
  {
    for (uint i = 0; i < array.length; ++i)
    {
      if (array[i] == msg.sender)
      {
        delete array[i];

        for(uint j = i; j < array.length-1; ++j)
        {
          array[j] = array[j+1];
        }

        break;
      }
    }
  }

  function cancel_vote(string memory proposal) public
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t) == false, "Vote is closed.");

    __delete_sender_from_array(t.votes_for);
    __delete_sender_from_array(t.votes_against);
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
    VoteTally storage t = proposals[proposal];

    require(is_crew(msg.sender), "Sender not allowed to submit proposals.");
    require(t.initialized == false, "Proposal does not exist.");
  
    t.initialized = true;
    t.start_time = now;
  }

  function vote(string memory proposal, bool for_or_against) public
  {
    VoteTally storage t = proposals[proposal];

    require(is_crew(msg.sender), "Sender not allowed to vote.");
    require(t.initialized, "Proposal does not exist.");
    require(__is_closed(t) == false, "Vote is closed.");

    if(__has_voted(t) == false)
    {
      if (for_or_against)
      {
        t.votes_for.push(msg.sender);
      }
      else
      {
        t.votes_against.push(msg.sender);
      }
    }
  }

  function has_voted(string memory proposal) internal constant returns(bool)
  {
    return __has_voted(proposals[proposal]);
  }

  function has_quorum(string memory proposal) public constant returns (bool)
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    return __total(t) > 2*members.length/3;
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
