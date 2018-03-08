pragma solidity 0.4.19;

contract ForceEtherVictim {

  function getBalance() constant returns (uint256) {
    return this.balance;
  }
}