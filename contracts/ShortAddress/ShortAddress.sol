pragma solidity ^0.4.19;

contract ShortAddress {
  mapping(address => uint256) balances;

  function transfer(address _addr, uint256 _value) {
    balances[_addr] = _value;
  }

  function balanceOf(address _addr) constant returns (uint256) {
    return balances[_addr];
  }
}