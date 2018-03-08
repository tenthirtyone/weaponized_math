import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const ForceEther = artifacts.require('ForceEther')
const ForceEtherVictim = artifacts.require('ForceEtherVictim')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Force Ether Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let victim = null
  let attacker = null

  beforeEach(async () => {
    victim = await ForceEtherVictim.new()
    attacker = await ForceEther.new()

    attacker.sendTransaction({value:oneEther});
  })

  describe('Victim', () => {
    it('Cannot receive Ether', async () => {
      await assertRevert(victim.sendTransaction({value: oneEther}));
    })
  })
  describe('Attacker', () => {
    it('Selfdestructs and sends Ether', async () => {
      await attacker.selfDestruct(victim.address);
      const bal = await victim.getBalance();

      bal.should.be.bignumber.equal(oneEther);
    })
  })
})

