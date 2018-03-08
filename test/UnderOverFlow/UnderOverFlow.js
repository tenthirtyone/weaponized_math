import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const Flow = artifacts.require('Flow')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Under/Overflow Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let flow = null

  beforeEach(async () => {
    flow = await Flow.new()
  })

  describe('Under/Overflow', () => {
    it('underflows', async () => {
      const retVal = await flow.underflow();

      retVal.should.be.bignumber.equal(252);
    })
    it('overflows', async () => {
      const retVal = await flow.overflow();

      retVal.should.be.bignumber.equal(2);
    })
    it('never ends', async () => {
      //await flow.neverEnds();
    })
  })
})

