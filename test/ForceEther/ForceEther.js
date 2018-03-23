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

    await attacker.sendTransaction({value:oneEther});
  })

  describe('Using selfdestruct', async () => {
    describe('Victim', () => {
      it('Cannot receive Ether', async () => {
        await assertRevert(victim.sendTransaction({ value: oneEther }));
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

  describe('Using predetermination', async () => {
    it('Send ether before the contract exists', async () => {
      // 0xb91f286fd4afa02f7099926f7cec8ad14f779b85 = SHA3(RLP(mallory, 1));
      await web3.eth.sendTransaction({ to: "0xb91f286fd4afa02f7099926f7cec8ad14f779b85", value: oneEther, from: creator });
      const victimMal = await ForceEtherVictim.new({ from: mallory })
      const balance = await victimMal.getBalance();
      balance.should.be.bignumber.equal(oneEther);
    })
  })
})

