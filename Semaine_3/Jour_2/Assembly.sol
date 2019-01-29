//Write your own contracts here. Currently compiles using solc v0.4.15+commit.bbb8e64f.
pragma solidity ^0.4.25;

contract Crew
{
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
    address[] votes_for;
    address[] votes_against;
    bool initialized;
    bool closed;
  }

  function delete_address_from_array(address[] storage array, uint index) internal
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
    require(t.closed == false, "Vote is closed.");

    for (uint i = 0; i < t.votes_for.length; ++i)
    {
      if (t.votes_for[i] == msg.sender)
      {
        delete_address_from_array(t.votes_for, i);
        break;
      }
    }

    for (i = 0; i < t.votes_against.length; ++i)
    {
      if (t.votes_against[i] == msg.sender)
      {
        delete_address_from_array(t.votes_against, i);
        break;
      }
    }
  }

  function has_voted(string memory proposal) public constant returns(bool)
  {
    VoteTally storage t = proposals[proposal];

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

  function vote_for(string memory proposal) internal
  {
    if (has_voted(proposal) == false)
    {
      proposals[proposal].votes_for.push(msg.sender);
    }
  }

  function vote_against(string memory proposal) internal
  {
    if(has_voted(proposal) == false)
    {
      proposals[proposal].votes_against.push(msg.sender);
    }
  }

  function total(VoteTally t) internal pure returns (uint)
  {
    return t.votes_for.length + t.votes_against.length;
  }

  function tally(VoteTally t) internal pure returns (bool)
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
    require(is_crew(msg.sender), "Sender not allowed to vote.");
    require(proposals[proposal].initialized, "Proposal does not exist.");
    require(proposals[proposal].closed == false, "Vote is closed.");

    if (for_or_against)
    {
      vote_for(proposal);
    }
    else
    {
      vote_against(proposal);
    }
  }

  function has_quorum(string memory proposal) public constant returns (bool)
  {
    require(proposals[proposal].initialized, "Proposal does not exist.");
    return total(proposals[proposal]) > 2*members.length/3;
  }

  function is_closed(string memory proposal) public constant returns (bool)
  {
    VoteTally storage t = proposals[proposal];
    require(t.initialized, "Proposal does not exist.");
    return t.closed || total(t) == members.length;
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
    require(t.closed, "Vote is not closed yet.");
    return tally(proposals[proposal]);
  }

  function cancel_proposal(string memory proposal) public
  {
    VoteTally storage t = proposals[proposal];
    require(owner == msg.sender, "Only owner can cancel a proposal.");
    require(t.initialized, "Proposal does not exist.");
    require(t.closed == false, "Vote is closed.");

    t.initialized = false;
    delete t.votes_for;
    delete t.votes_against;
  }
}
