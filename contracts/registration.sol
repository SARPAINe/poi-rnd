// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "./hangout.sol";
import "./interface.sol";

contract registration {

   address owner;
    
    uint public genesisBlock;
    uint public deadLine;
    uint public hangoutCountdown;
    
    uint public groupSize;
   
    /* these are used for the registration, randomization process and to assing users into groups */
    mapping(address => bool) public registered;
    address[] registeredUsers;
    uint256[] randomizedTemplate;

    mapping(address => uint) public userGroup;
    uint groupCount;
    
    /* these are used for booting up the hangout sessions */
    address[][] hangoutGroups;
    mapping(uint => bytes32) public hangoutAddressRegistry;
    mapping (address => bool) hangoutInSession;

    /* when you issue POIs, you pass along a list of verified users */
    address[] verifiedUsers;
    uint passVerifiedUsersDeadLine;

    /* the deposits are managed by the depositGovernance contract, so registration contract only 
       stores depositSize and the address for the depositContract */
    
    uint depositSize;
    address depositContract;

    constructor(uint _depositSize, uint registrationPeriod, uint _hangoutCountdown, uint _groupSize){
        groupSize = _groupSize;
        genesisBlock = block.number;
        deadLine = genesisBlock + registrationPeriod;
        hangoutCountdown = _hangoutCountdown;
        depositSize = _depositSize;
        owner = msg.sender;
    }
    
    function getBlockNumber() public view returns(uint){
        return block.number;
    }

    function setDepositContract(address _depositContract) public{
        depositContract=_depositContract;
    }

    function register() public payable returns (bool){
        if(block.number > deadLine) revert("block number greater than deadline");
        if(msg.value < depositSize * 100 wei) revert("need to stake certain amount of money to register");
        if(registered[msg.sender] == true) revert("already registerd!");
        registeredUsers.push(msg.sender);
        registered[msg.sender] = true;
	    IdepositGovernance(depositContract).registrationDeposit{value: msg.value}(msg.sender);
        return true;
    }


    function generateRandomNumber(uint nonce) public view returns(uint256){
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(this, nonce))) % 24 + 1;
        return randomNumber;
    // do something with randomNumber
    }
    function generateGroups() public {
        if(block.number < deadLine) revert("error4");

/* ether-poker's algorithm for shuffling a deck of cards is used to shuffle the list of registered users */

        uint8[2*20] memory unshuffled;

        for (uint8 i=0; i < registeredUsers.length; i++) {
            unshuffled[i] = i;
        }

        uint listIndex;

        for (uint8 i=0; i < registeredUsers.length; i++) {
            listIndex = generateRandomNumber(i) % (registeredUsers.length - i);
            randomizedTemplate.push(unshuffled[listIndex]);
            unshuffled[listIndex] = unshuffled[registeredUsers.length - i - 1];
        }
   
/* the randomized list is then used to assign users into groups */

        uint groupCount;
        uint counter;

        for(uint8 i = 0; i < randomizedTemplate.length; i++){
            if(counter == groupSize){ groupCount++; counter = 0;}
            userGroup[registeredUsers[randomizedTemplate[i]]] = groupCount;
            hangoutGroups[groupCount].push(registeredUsers[randomizedTemplate[i]]);
            counter++;
        }
	
/* hangout addresses are generated and mapped to hangout groups */

        for(uint8 i = 0; i < groupCount; i++){
                hangoutAddressRegistry[i]= keccak256(abi.encodePacked(hangoutGroups[i]));
        }
    }

    function getHangoutAddress() public view returns(bytes32){
        if(hangoutAddressRegistry[userGroup[msg.sender]] == 0) revert("error5");
        // maybe use http://appear.in for first version
        // hangoutURL = "http://appear.in" + hangoutAddressRegistry[userGroup[msg.sender]]
        return hangoutAddressRegistry[userGroup[msg.sender]];
    }


    function bootUpHangouts() public  {
    	if(block.number < hangoutCountdown) revert("error6");
        for (uint i = 0; i < groupCount; i++){
            address b = (address)(new hangout(hangoutGroups[groupCount]));
            hangoutInSession[b] = true;
        }
    }
    

    function passVerifiedUsers(address[] calldata verified) public  {
        if(hangoutInSession[msg.sender] != true) revert("error7"); // can only be invoked by hangout contract
        if(passVerifiedUsersDeadLine == 0) passVerifiedUsersDeadLine = block.number + 100; // give everyone enough time to submit their verified addresses
        if(block.number > passVerifiedUsersDeadLine) revert("error8"); // deadLine has passed and POIs have already started being issued
        
        for (uint i = 0; i < verified.length; i++)
            verifiedUsers.push(verified[i]);
        
        hangoutInSession[msg.sender] == false;
    }
    
    function issuePOIs() public {
        if(block.number < passVerifiedUsersDeadLine) revert("error9"); // hangouts are still in session
            Ipoi(owner).issuePOIs(verifiedUsers);
            
    }
    function endRound() public{
        if(msg.sender != owner) revert("Only the of the contract can end round or suicide contract");
        // suicide(owner);
        address payable payableOwner=payable(owner);
        selfdestruct(payableOwner);
    }
    
    // function killContract() public{
    //     if(msg.sender != mainContract) revert("error15");
    //     address payable payableAddress=payable(mainContract);
    //     selfdestruct(payableAddress);
    // }
}