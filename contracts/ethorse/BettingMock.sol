pragma solidity ^0.4.19;

import './Betting.sol';

contract BettingMock is Betting {
  function _calculateReward(address candidate, bytes32 horse) public constant returns (uint winner_reward) {
    winner_horse[horse] = true;
    total_reward = 1 ether;
    return calculateReward(candidate);
  }

  function _createBets(uint256 numberOfBets, bytes32 horse) public {
    for (uint256 i = 0; i < numberOfBets; i++) {
      bet_info memory current_bet;
      current_bet.amount = msg.value;
      current_bet.horse = horse;
      voterIndex[msg.sender].bets.push(current_bet);
      voterIndex[msg.sender].bet_count = voterIndex[msg.sender].bet_count.add(1);
      coinIndex[horse].total = (coinIndex[horse].total).add(msg.value);
      coinIndex[horse].count = coinIndex[horse].count.add(1);
      Deposit(msg.sender, msg.value);
    }
  }
}