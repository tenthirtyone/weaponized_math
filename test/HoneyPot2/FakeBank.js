import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const FakeBank = artifacts.require('FakeBank')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Honey Pot 2 Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let bank = null

  beforeEach(async () => {
    bank = await FakeBank.new()

  })

  describe('Bank', () => {
    it('Makes a deposit', async () => {
      await bank.sendTransaction({ value: oneEther });
      const balance = await bank.balanceOf(creator);

      balance.should.be.bignumber.equal(oneEther);
    })
    it('Fails to make a withdrawal', async () => {
      await bank.sendTransaction({ value: oneEther });
      await bank.withdraw(creator);
      const balance = await bank.balanceOf(creator);

      balance.should.be.bignumber.equal(oneEther);
    })
  })
})

