// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./registration.sol";
import "./generatePOIs.sol";
import "./interface.sol";
import "./depositGovernance.sol";
contract poi {
    
    address currentPOItokens;
    address currentRound;
    address depositGovernanceContract;
    address previousDepositGovernance;	    
    
    uint genesisblock;
    uint roundLength;
    uint registrationPeriod;
    uint hangoutCountdown;
    uint nextRound;
    
    uint depositSize;
    uint groupSize;
    
    constructor(){
        genesisblock = block.number;

        //here 172800 is the number of blocks ethreum can have in one month, 
        //assuming each block is added after 15s
        roundLength = 172800; // set POI pseudonym parties to happen once a month

        //start time of the round
        nextRound = genesisblock;
        
        //how many ether needs to stake
        depositSize = 5;

        //This line sets the registrationPeriod variable to 29/30 (approximately 97%) of the roundLength
        registrationPeriod = roundLength * 29/30; // 29 days
		
        //This is the amount of time during the registrationPeriod 
        //when participants can form groups and join POI hangouts.
        hangoutCountdown = registrationPeriod * 23/24; // 23 hours
		
        //number of participants required to form a poi group.
        groupSize = 5;
	
        scheduleRound();
    }
    
    
    function scheduleRound() public {
        if(block.number < nextRound) revert("You have to wait a certain period of time to schedule next round");
        if(currentRound != address(0)) registration(currentRound).endRound();
        currentRound = (address)(new registration(depositSize, registrationPeriod, hangoutCountdown, groupSize));
        
        nextRound += roundLength;
    }

    function issuePOIs(address[] memory verifiedUsers) public  {
        if(msg.sender != currentRound) revert("error2");
        if(currentPOItokens !=address(0)) generatePOIs(currentPOItokens).depricatePOIs;
        currentPOItokens = (address)(new generatePOIs(verifiedUsers));
        
        // now that the a new POI round has begun and the deposits have been returned,
        // launch a new depositGovernanceContract
        // if a new depositSize has been agreed on, the old depositGovernanceContract will automatically
        // invoke the newDepositSize() function (see below) 
        
        newDepositGovernanceContract();
    }
    
    function newDepositGovernanceContract() internal{
        if(depositGovernanceContract != address(0)) {
        	IdepositGovernance(depositGovernanceContract).processProposals();
        	previousDepositGovernance = depositGovernanceContract; // processProposals() will take a few minutes, so use a temporary address, previousDepositGovernance, for newDepositSize() for now
        }
        depositGovernanceContract = (address)(new depositGovernance());
        /* deposits paid into voting for depositSizes should be deducatable from the deposit required to register */
        /* that's not implemented yet. stub on https://gist.github.com/resilience-me/0afcb1d692bb815de9ed */
    }

    function newDepositSize(uint _newDepositSize) public {
        if(msg.sender != previousDepositGovernance) revert("error3");
        depositSize = _newDepositSize;
    }
    
    function verifyPOI (address v) public view returns (string memory){
	    if (generatePOIs(currentPOItokens).balanceOf(v)==0){
		    return "account does not have a valid POI";
	    }
    	else return "account has a valid POI";
    }      
    
}