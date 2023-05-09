// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./interface.sol";

contract depositGovernance {
    address owner;
    address registrationContract;

    /* manage deposits */

    mapping (address => uint256) public deposits; // deposits that have not been used as votes
    mapping (address => uint256) votes; // deposited ether that has been used to vote

    mapping (address => uint256) addressIndex;

    address[] depositRegistry;


    struct proposeNewDeposit {
        uint256 depositSize;
        uint256 votesInFavour; // in ether
        uint256 votesAgainst;  // in ether

    }

    proposeNewDeposit[] proposals;



    constructor(){
    owner = msg.sender;
    }

    function setRegistrationContract(address _registrationContract) public{
        registrationContract=_registrationContract;
    }
    // contract registration calls registrationDeposit(msg.sender).value(msg.value)

    function registrationDeposit(address registrant) public payable{
        if(msg.sender != registrationContract) revert("message.sender is not registration contract");
        deposits[registrant] += msg.value;
        if(addressIndex[registrant] == 0)

        depositRegistry.push(registrant);

    }

    function NewProposal(uint256 depositSize) public payable {
        if(msg.value < depositSize * 1 ether) revert("error2");
        proposals.push(proposeNewDeposit({
            depositSize: depositSize,
            votesInFavour: 0,
            votesAgainst: 0
        }));
        
       deposits[msg.sender] += msg.value / 1 ether;
       if(addressIndex[msg.sender] == 0)
            depositRegistry.push(msg.sender);
            addressIndex[msg.sender] = depositRegistry.length;


       /* add surplus to votesInFavour */
       if(msg.value > depositSize * 1 ether)
       proposals[proposals.length].votesInFavour += msg.value/1 ether - depositSize;
    }

    function voteOnProposal(uint proposalIndex, bool opinion) public payable {
        if(msg.value < proposals[proposalIndex].depositSize * 1 ether) revert("error3");
        
        if(opinion == true)
        proposals[proposalIndex].votesInFavour += msg.value * 1 ether;
        else
        proposals[proposalIndex].votesAgainst += msg.value * 1 ether;

       deposits[msg.sender] += msg.value / 1 ether;
       if(addressIndex[msg.sender] == 0)
            depositRegistry.push(msg.sender);
            addressIndex[msg.sender] = depositRegistry.length;
    }

    function processProposals() public { // invoked at the end of each round
        if(msg.sender != owner) revert("erro4");
        uint iterateToHighest;
        
        for (uint i = 0; i < proposals.length; i++){
            if(proposals[i].votesInFavour > proposals[i].votesAgainst && proposals[iterateToHighest].votesInFavour < proposals[i].votesInFavour)
            iterateToHighest = i;
        }
    
        if(proposals[iterateToHighest].votesInFavour > 0) {
            uint newDepositSize = proposals[iterateToHighest].depositSize;
        
            /* pass newDepositSize to poi contract */
        
            Ipoi(owner).newDepositSize(newDepositSize);
        }
    
         /* then return deposits */
    
        for (uint k = depositRegistry.length; k < 0 ; k++){
            address payable recipient = payable(depositRegistry[k]);
            recipient.send(deposits[depositRegistry[k]]);
        }
            
        /* then suicide contract */
        if(depositRegistry.length == 0){
            address payable payableOwner=payable(owner);
            selfdestruct(payableOwner);
        }
    }
}