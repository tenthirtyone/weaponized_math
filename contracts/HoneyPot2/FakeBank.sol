pragma solidity ^0.4.19;

contract FakeBank {
  address owner;
  mapping (address => uint256) balances;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function FakeBank() {
    owner = msg.sender;
  }

  function () payable {
    balances[msg.sender] += msg.value;
  }

  function withdraw(address _addr) {
    msg.sender.call.value(balances[_addr]);
  }

  function balanceOf(address _addr) constant returns (uint256) {
    return balances[_addr];
  }

  function selfDestruct() onlyOwner {
    selfdestruct(owner);
  }
}