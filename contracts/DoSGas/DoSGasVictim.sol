pragma solidity ^0.4.19;

contract DoSGasVictim {
  address[] public users;
  bytes20[] hashes;

  function addUser(address _addr) public {
    users.push(_addr);
  }

  function loopUsers() {
    for(uint i = 0; i < users.length; i++) {
      hashes.push(ripemd160(users[i]));
    }
  }

  function totalUsers() constant returns (uint256) {
    return users.length;
  }
}