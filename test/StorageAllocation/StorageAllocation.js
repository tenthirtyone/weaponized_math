import assertRevert, { assertError } from '../helpers/assertRevert'
import { increaseTimeTo, duration } from '../helpers/increaseTime';

const BigNumber = web3.BigNumber

const StorageAllocation = artifacts.require('StorageAllocation')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Storage Allocation Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  const oneEther = 10e18;
  let storage = null

  beforeEach(async () => {
    storage = await StorageAllocation.new()
  })

  describe('Contract', () => {
    it('Has an owner', async () => {
      const owner = await storage.getOwner();
      owner.should.be.equal(creator);
    })
    it('Breaks the Contract by changing the owner', async () => {
      // View storage for contract
      //console.log(await web3.eth.getStorageAt(storage.address, 0));
      await storage.breakContract(mallory);
      const owner = await storage.getOwner();
      owner.should.be.equal(mallory);
      //console.log(await web3.eth.getStorageAt(storage.address, 0));
    })
  })
})

