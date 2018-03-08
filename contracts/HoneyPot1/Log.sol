pragma solidity 0.4.19;

contract Log {
  address private owner;
  address private ethAddress;

  struct Message {
    address sender;
    uint256 amount;
    string note;
  }

  Message[] History;
  Message public LastLine;

  function Log() {
    owner = msg.sender;
    ethAddress = msg.sender;
  }

  function changeEthAddress(address _addr) {
    require(msg.sender == owner);
    ethAddress = _addr;
  }

  function LogTransfer(address _sender, uint256 _amount, string _note) {
    if (keccak256(_note) == keccak256("withdraw")) {
      require(_sender == ethAddress);
    }
    LastLine.sender = _sender;
    LastLine.amount = _amount;
    LastLine.note = _note;
    History.push(LastLine);
  }
}