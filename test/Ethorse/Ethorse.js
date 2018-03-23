import assertRevert, { assertError } from '../helpers/assertRevert'
import expectThrow from '../helpers/expectThrow'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const Betting = artifacts.require('BettingMock')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Betting Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let dapp = null


  beforeEach(async () => {
    dapp = await Betting.new();
  })

  describe('Victim', () => {
    it('Exists', async () => {
      console.log(dapp.address);
    })
    it('Creates 20,000 bets and runs out of gas calculating the reward', async () => {
      console.log('0 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('2,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('4,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('6,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('8,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('10,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('12,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('14,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('16,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('18,000 / 20,000')
      await dapp._createBets(2000, 0);
      console.log('20,000 / 20,000')
      await assertRevert(dapp._calculateReward(creator, 0));
    })
  })
})

