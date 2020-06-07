// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Voting {
    //struct qui définit le profil des électeurs
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
    }
    //struct représentant une proposition de vote
    struct Proposal {
        uint8 id; 
        uint voteCount;
    }
   //Enumération qui représente les différentes phases du scrutin
    enum Stage {
        Init,
        Registration, 
        Vote, 
        Done
    }
    Stage public stage = Stage.Init;
    
    address _chairperson;
    mapping(address => Voter) _voters;
    Proposal[] _proposals;

    event votingCompleted();
    
    uint _startTime;
    //modifiers
    modifier validStage(Stage reqStage)
    { require(stage == reqStage);
      _;
    }
    
   constructor(uint8[] memory proposals_) public {
        _chairperson = msg.sender;
        _voters[_chairperson].weight = 2; //Pour des raisons de tests

        for (uint i = 0; i < proposals_.length; i++) {
            _proposals.push(Proposal({
                id: proposals_[i],
                voteCount: 0
            }));
        }
        stage = Stage.Registration;
        _startTime = now;
    }
    
    function register(address toVoter) public validStage(Stage.Registration) {
        if (msg.sender != _chairperson || _voters[toVoter].voted) return;
        _voters[toVoter].weight = 1;
        _voters[toVoter].voted = false;
        if (now > (_startTime+ 30 seconds)) {stage = Stage.Vote; }        
    }
    
    function vote(uint8 toProposal) public validStage(Stage.Vote)  {
        Voter storage sender = _voters[msg.sender];
        if (sender.voted || toProposal >= _proposals.length) return;
        sender.voted = true;
        sender.vote = toProposal;   
        _proposals[toProposal].voteCount += sender.weight;
        if (now > (_startTime+ 60 seconds)) {
           stage = Stage.Done; 
           emit votingCompleted();
        }
    }

   function winningProposal() public view returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint i = 0; i < _proposals.length; i++) {
            if (_proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = _proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

}