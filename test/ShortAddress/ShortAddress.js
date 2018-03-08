import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const ShortAddress = artifacts.require('ShortAddress')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Short Address Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let victim = null

  beforeEach(async () => {
    victim = await ShortAddress.new()
  })

  describe('Contract', () => {
    /*
     * 0xa9059cbb00000000000000000000000000df08f82de32b8d460adbe8d72043e3a7e25a3b00000000000000000000000000000000000000000000000000000000000003e8
     *
     * a9059cbb - keccak256(transfer(address,uint256))
     * 00000000000000000000000000df08f82de32b8d460adbe8d72043e3a7e25a3b - shortAddr fixed by web3
     * 000000000000000000000000df08f82de32b8d460adbe8d72043e3a7e25a3b39 - creator
     */
    it('Web3 Fixes the shortened Address', async () => {
      const shortAddr = creator.slice(0, creator.length-2);
      const receipt = await victim.transfer(creator, 1000);
      const bal = await victim.balanceOf(creator);
    })
  })
})