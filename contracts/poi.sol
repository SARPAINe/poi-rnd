// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./registration.sol";
import "./generatePOIs.sol";
import "./interface.sol";
import "./depositGovernance.sol";
contract poi {
    
    address public currentPOItokens;
    address public currentRound;
    address public depositGovernanceContract;
    address public previousDepositGovernance;	    
    
    uint genesisblock;
    uint roundLength;
    uint registrationPeriod;
    uint hangoutCountdown;
    uint nextRound;
    
    uint depositSize;
    uint groupSize;
    
    constructor(uint _depositSize,uint _groupSize){
        genesisblock = block.number;

        //here 172800 is the number of blocks ethreum can have in one month, 
        //assuming each block is added after 15s
        roundLength = 172800; // set POI pseudonym parties to happen once a month

        //start time of the round
        nextRound = genesisblock;
        
        //how many ether needs to stake
        depositSize = _depositSize;

        //This line sets the registrationPeriod variable to 29/30 (approximately 97%) of the roundLength
        registrationPeriod = roundLength * 29/30; // 29 days
		
        //This is the amount of time during the registrationPeriod 
        //when participants can form groups and join POI hangouts.
        hangoutCountdown = registrationPeriod * 23/24; // 23 hours
		
        //number of participants required to form a poi group.
        groupSize = _groupSize;

        // depositGovernanceContract=_depositGovernanceContract;
        newDepositGovernanceContract();
        scheduleRound();
    }
    
    
    function scheduleRound() public {
        if(block.number < nextRound) revert("You have to wait a certain period of time to schedule next round");
        if(currentRound != address(0)) registration(currentRound).endRound();
        currentRound = (address)(new registration(depositSize, registrationPeriod, hangoutCountdown, groupSize,depositGovernanceContract));
        // new registration(depositSize, registrationPeriod, hangoutCountdown, groupSize,depositGovernanceContract);
        
        nextRound += roundLength;
    }
    
       //must call first
    function newDepositGovernanceContract() internal {
        // if(depositGovernanceContract != address(0)) {
        // 	IdepositGovernance(depositGovernanceContract).processProposals();
        // 	previousDepositGovernance = depositGovernanceContract; // processProposals() will take a few minutes, so use a temporary address, previousDepositGovernance, for newDepositSize() for now
        // }
        depositGovernanceContract = (address)(new depositGovernance());
    }
    
    function verifyPOI (address v) external view returns (string memory){
	    if (generatePOIs(currentPOItokens).balanceOf(v)==0){
		    return "account does not have a valid POI";
	    }
    	else return "account has a valid POI";
    }     

    function issuePOIs(address[] memory verifiedUsers) public  {
        if(msg.sender != currentRound) revert("Poi token can only be issued from registration contract.");
        if(currentPOItokens !=address(0)) generatePOIs(currentPOItokens).depricatePOIs;
        currentPOItokens = (address)(new generatePOIs(verifiedUsers));
    }
}