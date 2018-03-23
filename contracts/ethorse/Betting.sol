pragma solidity ^0.4.19;
import "./lib/usingOraclize.sol";
import "./lib/SafeMath.sol";

contract Betting is usingOraclize {
    using SafeMath for uint256; //using safemath

    bytes32 coin_pointer; // variable to differentiate different callbacks
    bytes32 temp_ID; // temp variable to store oraclize IDs
    uint countdown=3; // variable to check if all prices are received
    address public owner; //owner address
    uint public kickStarter = 0; // ethers to kickcstart the oraclize queries

    uint public winnerPoolTotal;
    string public constant version = "0.2.1.beta";

    struct chronus_info {
        bool  betting_open; // boolean: check if betting is open
        bool  race_start; //boolean: check if race has started
        bool  race_end; //boolean: check if race has ended
        bool  voided_bet; //boolean: check if race has been voided
        uint  starting_time; // timestamp of when the race starts
        uint  betting_duration;
        uint  race_duration; // duration of the race
        uint voided_timestamp;
    }

    struct horses_info{
        int  BTC_delta; //horses.BTC delta value
        int  ETH_delta; //horses.ETH delta value
        int  LTC_delta; //horses.LTC delta value
        bytes32 BTC; //32-bytes equivalent of horses.BTC
        bytes32 ETH; //32-bytes equivalent of horses.ETH
        bytes32 LTC;  //32-bytes equivalent of horses.LTC
        uint customGasLimit;
    }

    struct bet_info{
        bytes32 horse; // coin on which amount is bet on
        uint amount; // amount bet by Bettor
    }
    struct coin_info{
        uint total; // total coin pool
        uint pre; // locking price
        uint post; // ending price
        uint count; // number of bets
        bool price_check; // boolean: differentiating pre and post prices
    }
    struct voter_info {
        uint bet_count; //number of bets
        bool rewarded; // boolean: check for double spending
        bet_info[] bets; //array of bets
    }


    mapping (bytes32 => bytes32) oraclizeIndex; // mapping oraclize IDs with coins
    mapping (bytes32 => coin_info) coinIndex; // mapping coins with pool information
    mapping (address => voter_info) voterIndex; // mapping voter address with Bettor information

    uint public total_reward; // total reward to be awarded
    mapping (bytes32 => bool) public winner_horse;


    // tracking events
    event newOraclizeQuery(string description);
    event newPriceTicker(uint price);
    event Deposit(address _from, uint256 _value);
    event Withdraw(address _to, uint256 _value);

    // constructor
    function Betting() payable {
        //oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
        kickStarter = kickStarter.add(msg.value);
        // oraclize_setCustomGasPrice(10000000000 wei);
        horses.BTC = bytes32("BTC");
        horses.ETH = bytes32("ETH");
        horses.LTC = bytes32("LTC");
        horses.customGasLimit = 300000;
    }

    // data access structures
    horses_info public horses;
    chronus_info public chronus;

    // modifiers for restricting access to methods
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    modifier duringBetting {
        require(chronus.betting_open);
        _;
    }

    modifier beforeBetting {
        require(!chronus.betting_open && !chronus.race_start);
        _;
    }

    modifier afterRace {
        require(chronus.race_end);
        _;
    }

    //oraclize callback method
    function __callback(bytes32 myid, string result, bytes proof) {
        require (msg.sender == oraclize_cbAddress());
        chronus.race_start = true;
        chronus.betting_open = false;
        coin_pointer = oraclizeIndex[myid];

        if (!coinIndex[coin_pointer].price_check) {
            coinIndex[coin_pointer].pre = stringToUintNormalize(result);
            coinIndex[coin_pointer].price_check = true;
            newPriceTicker(coinIndex[coin_pointer].pre);
        } else if (coinIndex[coin_pointer].price_check){
            coinIndex[coin_pointer].post = stringToUintNormalize(result);
            newPriceTicker(coinIndex[coin_pointer].post);
            countdown = countdown - 1;
            if (countdown == 0) {
                reward();
            }
        }
    }

    // place a bet on a coin(horse) lockBetting
    function placeBet(bytes32 horse) external duringBetting payable  {
        require(msg.value >= 0.01 ether);
        bet_info memory current_bet;
        current_bet.amount = msg.value;
        current_bet.horse = horse;
        voterIndex[msg.sender].bets.push(current_bet);
        voterIndex[msg.sender].bet_count = voterIndex[msg.sender].bet_count.add(1);
        coinIndex[horse].total = (coinIndex[horse].total).add(msg.value);
        coinIndex[horse].count = coinIndex[horse].count.add(1);
        Deposit(msg.sender, msg.value);
    }

    // fallback method for accepting payments
    function () private payable {}

    // method to place the oraclize queries
    function setupRace(uint delay, uint  locking_duration) onlyOwner beforeBetting payable returns(bool) {
        if (oraclize_getPrice("URL") > (this.balance)/6) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
            return false;
        } else {
            chronus.starting_time = block.timestamp;
            chronus.betting_open = true;
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            // bets open price query
            delay = delay.add(60); //slack time 1 minute
            chronus.betting_duration = delay;
            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/ethereum/).0.price_usd");
            oraclizeIndex[temp_ID] = horses.ETH;

            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/litecoin/).0.price_usd");
            oraclizeIndex[temp_ID] = horses.LTC;

            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/bitcoin/).0.price_usd");
            oraclizeIndex[temp_ID] = horses.BTC;

            //bets closing price query
            delay = delay.add(locking_duration);

            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/ethereum/).0.price_usd",horses.customGasLimit);
            oraclizeIndex[temp_ID] = horses.ETH;

            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/litecoin/).0.price_usd",horses.customGasLimit);
            oraclizeIndex[temp_ID] = horses.LTC;

            temp_ID = oraclize_query(delay, "URL", "json(http://api.coinmarketcap.com/v1/ticker/bitcoin/).0.price_usd",horses.customGasLimit);
            oraclizeIndex[temp_ID] = horses.BTC;

            chronus.race_duration = delay;
            return true;
        }
    }

    // method to calculate reward (called internally by callback)
    function reward() internal {
        /*
        calculating the difference in price with a precision of 5 digits
        not using safemath since signed integers are handled
        */
        horses.BTC_delta = int(coinIndex[horses.BTC].post - coinIndex[horses.BTC].pre)*10000/int(coinIndex[horses.BTC].pre);
        horses.ETH_delta = int(coinIndex[horses.ETH].post - coinIndex[horses.ETH].pre)*10000/int(coinIndex[horses.ETH].pre);
        horses.LTC_delta = int(coinIndex[horses.LTC].post - coinIndex[horses.LTC].pre)*10000/int(coinIndex[horses.LTC].pre);

        total_reward = coinIndex[horses.BTC].total.add(coinIndex[horses.ETH].total).add(coinIndex[horses.LTC].total);
        uint house_fee = total_reward.mul(5).div(100);
        // house_fee = house_fee.add(kickStarter);
        require(house_fee < this.balance);
        total_reward = total_reward.sub(house_fee);
        owner.transfer(house_fee);

        if (horses.BTC_delta > horses.ETH_delta) {
            if (horses.BTC_delta > horses.LTC_delta) {
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.BTC].total;
            }
            else if(horses.LTC_delta > horses.BTC_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else {
                winner_horse[horses.BTC] = true;
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.BTC].total.add(coinIndex[horses.LTC].total);
            }
        } else if(horses.ETH_delta > horses.BTC_delta) {
            if (horses.ETH_delta > horses.LTC_delta) {
                winner_horse[horses.ETH] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total;
            }
            else if (horses.LTC_delta > horses.ETH_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else {
                winner_horse[horses.ETH] = true;
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total.add(coinIndex[horses.LTC].total);
            }
        } else {
            if (horses.LTC_delta > horses.ETH_delta) {
                winner_horse[horses.LTC] = true;
                winnerPoolTotal = coinIndex[horses.LTC].total;
            } else if(horses.LTC_delta < horses.ETH_delta){
                winner_horse[horses.ETH] = true;
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total.add(coinIndex[horses.BTC].total);
            } else {
                winner_horse[horses.LTC] = true;
                winner_horse[horses.ETH] = true;
                winner_horse[horses.BTC] = true;
                winnerPoolTotal = coinIndex[horses.ETH].total.add(coinIndex[horses.BTC].total).add(coinIndex[horses.LTC].total);
            }
        }
        chronus.race_end = true;
    }

    // method to calculate an invidual's reward
    function calculateReward(address candidate) internal afterRace constant returns(uint winner_reward) {
        uint i;
        voter_info bettor = voterIndex[candidate];
        if (!chronus.voided_bet) {
            for(i=0; i<bettor.bet_count; i++) {
                if (winner_horse[bettor.bets[i].horse]) {
                    winner_reward += (((total_reward.mul(10000000)).div(winnerPoolTotal)).mul(bettor.bets[i].amount)).div(10000000);
                }
            }

        } else {
            for(i=0; i<bettor.bet_count; i++) {
                winner_reward += bettor.bets[i].amount;
            }
        }
    }

    // method to just check the reward amount
    function checkReward() afterRace constant returns (uint) {
        require(!voterIndex[msg.sender].rewarded);
        return calculateReward(msg.sender);
    }

    // method to claim the reward amount
    function claim_reward() afterRace {
        require(!voterIndex[msg.sender].rewarded);
        uint transfer_amount = calculateReward(msg.sender);
        require(this.balance > transfer_amount);
        voterIndex[msg.sender].rewarded = true;
        msg.sender.transfer(transfer_amount);
        Withdraw(msg.sender, transfer_amount);
    }

    // utility function to convert string to integer with precision consideration
    function stringToUintNormalize(string s) constant returns (uint result) {
        uint p =2;
        bool precision=false;
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            if (precision) {p = p-1;}
            if (uint(b[i]) == 46){precision = true;}
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {result = result * 10 + (c - 48);}
            if (precision && p == 0){return result;}
        }
        while (p!=0) {
            result = result*10;
            p=p-1;
        }
    }


    // exposing the coin pool details for DApp
    function getCoinIndex(bytes32 index) constant returns (uint, uint, uint, bool, uint) {
        return (coinIndex[index].total, coinIndex[index].pre, coinIndex[index].post, coinIndex[index].price_check, coinIndex[index].count);
    }

    // exposing the total reward amount for DApp
    function reward_total() constant returns (uint) {
        return (coinIndex[horses.BTC].total.add(coinIndex[horses.ETH].total).add(coinIndex[horses.LTC].total));
    }

    function getVoterIndex() constant returns (uint, bytes32, uint) {
        voter_info voterInfoTemp = voterIndex[msg.sender];
        return (voterInfoTemp.bet_count, voterInfoTemp.bets[0].horse, voterInfoTemp.bets[0].amount);
    }

    // in case of any errors in race, enable full refund for the Bettors to claim
    function refund() onlyOwner {
        require(now > chronus.starting_time.add(chronus.race_duration));
        require((chronus.betting_open && !chronus.race_start)
            || (chronus.race_start && !chronus.race_end));
        chronus.voided_bet = true;
        chronus.race_end = true;
        chronus.voided_timestamp=now;
    }

    // method to claim unclaimed winnings after 30 day notice period
    function recovery() onlyOwner{
        require((chronus.race_end && now > chronus.starting_time.add(chronus.race_duration).add(30 days))
            || (chronus.voided_bet && now > chronus.voided_timestamp.add(30 days)));
        owner.transfer(this.balance);
    }
}
