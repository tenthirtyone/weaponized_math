import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const Victim = artifacts.require('ReentrancyVictim')
const Attacker = artifacts.require('ReentrancyAttacker')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Reentrancy Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let victim = null
  let attacker = null

  beforeEach(async () => {
    victim = await Victim.new()
    attacker = await Attacker.new()
  })

  describe('Victim', () => {
    it('Deposits ether', async () => {
      const deposit = oneEther * 10;
      await victim.deposit({ value: deposit });
      const balOfUser = await victim.balanceOf(creator);
      balOfUser.should.be.bignumber.equal(deposit);

      const balOfContract = await victim.getContractBalance();
      balOfContract.should.be.bignumber.equal(deposit);
    })
    it('Makes a withdrawal', async () => {
      const deposit = oneEther * 10;
      await victim.deposit({ value: deposit });

      let balOf = await victim.getContractBalance();
      balOf.should.be.bignumber.equal(deposit);

      await victim.withdraw();
      balOf = await victim.getContractBalance();
      balOf.should.be.bignumber.equal(0);
    })
  })

  describe('Attacker', () => {
    beforeEach(async () => {
      const deposit = oneEther * 10;
      await victim.deposit({ value: deposit });

      attacker.sendTransaction({value: oneEther});
    })
    it('Is an evil sumbitch', async () => {
      const sumBitch = await attacker.isSumBitch();

      sumBitch.should.be.equal(true);
    })
    it('Sends ether to the victim', async () => {
      await attacker.makeDeposit(victim.address, oneEther);
      const attackerBalance = await victim.balanceOf(attacker.address)

      attackerBalance.should.be.bignumber.equal(oneEther);
    })
    it('Drains the victim contract', async () => {
      let attackContractBalance = await attacker.getContractBalance();

      await attacker.makeDeposit(victim.address, oneEther);
      let attackerBalance = await victim.balanceOf(attacker.address)

      attackerBalance.should.be.bignumber.equal(oneEther);

      let contractBalance = await victim.getContractBalance();
      contractBalance.should.be.bignumber.equal(oneEther * 11);

      await attacker.setTargetAmount(contractBalance);
      await attacker.makeWithdrawal(victim.address);

      contractBalance = await victim.getContractBalance();
      contractBalance.should.be.bignumber.equal(0);

      attackerBalance = await victim.balanceOf(attacker.address);
      attackerBalance.should.be.bignumber.equal(0);

      attackContractBalance = await attacker.getContractBalance();
      attackContractBalance.should.be.bignumber.equal(oneEther * 11);
    })
  })
})

