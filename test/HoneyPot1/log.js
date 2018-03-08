const BigNumber = web3.BigNumber
const Log = artifacts.require('Log')


require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

contract('Log Test', accounts => {
  const [creator, user, anotherUser, operator, mallory] = accounts
  let logger = null

  beforeEach(async () => {

    logger = await Log.new();
  })

  describe('Logger', () => {
    it('Stuff', async () => {
      // Does Stuff
    })
  })

})

