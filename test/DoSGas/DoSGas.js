import assertRevert, { assertError } from '../helpers/assertRevert'
import expectThrow from '../helpers/expectThrow'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const DoSGas = artifacts.require('DoSGas')
const DoSGasVictim = artifacts.require('DoSGasVictim')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('DoS Gas Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let victim = null
  let attacker = null

  beforeEach(async () => {
    victim = await DoSGasVictim.new()
    attacker = await DoSGas.new()

    attacker.sendTransaction({ value: oneEther });
  })

  describe('Victim', () => {
    it('Adds User', async () => {
      await victim.addUser(creator)
    })
    it('Loops Users', async () => {
      await victim.loopUsers()
    })
  })
  describe('Attacker', () => {
    it('adds 100 users', async () => {
      await attacker.addUsers(victim.address, 100);
    })
    /*
    it('Victim function runs out of gas', async () => {
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await attacker.addUsers(victim.address, 1000);
      await expectThrow(victim.loopUsers());
    })
    */
  })
})

