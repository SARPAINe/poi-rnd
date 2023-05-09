// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract generatePOIs {    
    
    address owner;
  
    string public name;
    string public symbol;
    uint8 public decimals;
    
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address[] memory verifiedUsers) {
        owner = msg.sender;
        balanceOf[owner] = verifiedUsers.length;            // Give the creator all initial tokens                    
        name = "POI";                                       // Set the name for display purposes     
        symbol = "POI";                                     // Set the symbol for display purposes    
        decimals = 0;                                       // Amount of decimals for display purposes        
    
      /* Send POIs to every verified address */

        for (uint i = 0; i < verifiedUsers.length; i++)
        {
           balanceOf[owner] -= 1;                                              
           balanceOf[verifiedUsers[i]] += 1;
           emit Transfer(owner, verifiedUsers[i], 1);            // Notify anyone listening that this transfer took place
        }
    }


    function depricatePOIs() public{
        if(msg.sender != owner) revert("error11");
        // suicide(owner);
        address payable payableOwner=payable(owner);
        selfdestruct(payableOwner);
    } 
}