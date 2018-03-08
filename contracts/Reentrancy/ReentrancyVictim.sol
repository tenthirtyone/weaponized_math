pragma solidity ^0.4.19;

contract ReentrancyVictim {
  mapping (address => uint256) balances;

  function deposit() payable {
    balances[msg.sender] += msg.value;
  }

  function withdraw() {
    msg.sender.call.value(balances[msg.sender])();
    balances[msg.sender] = 0;
  }

  function balanceOf(address addr) constant returns (uint256) {
    return balances[addr];
  }

  function getContractBalance() constant returns (uint256) {
    return this.balance;
  }
}