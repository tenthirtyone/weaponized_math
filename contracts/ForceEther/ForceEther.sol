pragma solidity ^0.4.19;

contract ForceEther {
  function() payable {

  }
  function selfDestruct(address _addr) {
    selfdestruct(_addr);
  }
}