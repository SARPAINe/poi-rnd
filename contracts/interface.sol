// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface IdepositGovernance{
    function registrationDeposit(address registrant) external payable;
    function processProposals() external;
}

interface Ipoi{
    function issuePOIs(address[] memory verifiedUsers) external;
    function newDepositSize(uint _newDepositSize) external;
}

interface Iregistration{
    function submitVerifiedUsers(address[] memory verified) external;
     function passVerifiedUsers(address[] calldata verified) external;
}