pragma solidity ^0.4.19;

contract Flow {

  function underflow() constant returns (uint8) {
    uint8 smallInt = 1;
    return smallInt - 5;
  }

  function overflow() constant returns (uint8) {
    uint8 smallInt = 255;
    return smallInt + 3;
  }

  function neverEnds() {
    uint256 bigInt = 1000;
    uint256 counter = 0;
    for (var i = 0; i < bigInt; i++) {
      counter++;
    }
  }
}