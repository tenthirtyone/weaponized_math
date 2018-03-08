pragma solidity ^0.4.19;

contract DoSRevertVictim {
  address kingOfPonzi;
  uint256 kingFee;

  function DoSRevertVictim() {
    kingOfPonzi = msg.sender;
    kingFee = msg.value;
  }

  function becomeKing() payable {
    require(msg.value > kingFee);
    require(kingOfPonzi.send(kingFee));

    kingFee = msg.value;
    kingOfPonzi = msg.sender;
  }

  function getKing() constant returns (address) {
    return kingOfPonzi;
  }
}