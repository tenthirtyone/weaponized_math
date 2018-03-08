const BigNumber = web3.BigNumber
const Log = artifacts.require('Log')
const TrustFund = artifacts.require('TrustFund')


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Honey Pot Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  let trust = null
  let logger = null
  let deposit = 1000000000000000000;

  beforeEach(async () => {
    logger = await Log.new();
    trust = await TrustFund.new(100000000000000000, logger.address);

  })

  describe('Logger', () => {
    it('Makes a deposit', async () => {
      await trust.deposit({ from: creator, value: deposit});
      const balance = await trust.checkBalance(creator);
      balance.should.be.bignumber.equal(deposit);
    })
    it('Makes a withdrawal', async () => {
      await trust.deposit({ from: creator, value: deposit});
      await trust.withdraw(deposit);
      const balance = await trust.checkBalance(creator);
      balance.should.be.bignumber.equal(0);
    })
    it('Makes a deposit from another account', async () => {
      await trust.deposit({ from: mallory, value: deposit});
      const balance = await trust.checkBalance(mallory);
      balance.should.be.bignumber.equal(deposit);
    })
    it('Makes a withdrawal from another account and fails', async () => {
      await trust.deposit({ from: mallory, value: deposit});
      try {
        await trust.withdraw(deposit, { from: mallory });
      } catch (e) {
        if (e.toString().indexOf('revert') >= 0) {
          console.log('Withdraw Reverted. Ooooo it burns');
        }
      }

      const balance = await trust.checkBalance(mallory);
      balance.should.be.bignumber.equal(deposit);
    })
  })

})

