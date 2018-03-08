pragma solidity ^0.4.19;

contract Homoglyph {
  mapping (string => uint256) balances;

  function () payable {
    balances['result'] += msg.value;
  }

  // Cyrillic 'e' in result
  function getBalance() constant returns (uint256) {
    return balances['rеsult'];
  }
}