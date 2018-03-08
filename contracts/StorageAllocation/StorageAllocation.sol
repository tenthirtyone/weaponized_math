pragma solidity ^0.4.19;

contract StorageAllocation {
  address owner;

  struct User {
    address account;
  }

  function StorageAllocation() {
    owner = msg.sender;
  }

  function breakContract(address _addr) {
    User u;
    u.account = _addr;
  }

  function getOwner() constant returns (address) {
    return owner;
  }
}