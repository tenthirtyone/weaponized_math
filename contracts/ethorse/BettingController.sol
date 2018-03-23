pragma solidity ^0.4.19;

import {Betting as Race, usingOraclize} from "./Betting.sol";

contract BettingController is usingOraclize {
    address owner;
    bool public paused;
    uint256 oraclizeGasLimit;
    uint256 raceKickstarter;
    uint256 recoveryDuration;
    Race race;

    struct raceInfo {
        uint256 spawnTime;
        uint256 bettingDuration;
        uint256 raceDuration;
    }

    struct recoveryIndexInfo {
        address raceContract;
        bool recoveryNeeded;
    }

    struct oraclizeIndexInfo {
        uint256 delay;
        uint256 bettingDuration;
        uint256 raceDuration;
    }

    mapping (address => raceInfo) public raceIndex;
    mapping (bytes32 => recoveryIndexInfo) recoveryIndex;
    mapping (bytes32 => oraclizeIndexInfo) oracleIndex;
    event RaceDeployed(address _address, address _owner, uint256 _bettingDuration, uint256 _raceDuration, uint256 _time);
    event HouseFeeDeposit(address indexed _race, uint256 _value);
    event newOraclizeQuery(string description);
    event AddFund(uint256 _value);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier whenNotPaused {
        require(!paused);
        _;
    }

    function BettingController() public payable {
        owner = msg.sender;
        oraclizeGasLimit = 4000000;
        raceKickstarter = 0.1 ether;
        recoveryDuration = 30 days;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    }

    function addFunds() external onlyOwner payable {
        AddFund(msg.value);
    }

    function () external payable{
        HouseFeeDeposit(msg.sender, msg.value);
    }

    function spawnRace(uint256 _bettingDuration, uint256 _raceDuration) internal whenNotPaused {
        require(!paused);
        bytes32 oracleRecoveryQueryId;
        race = (new Race).value(raceKickstarter)();

        raceIndex[race].spawnTime = now;
        raceIndex[race].bettingDuration = _bettingDuration;
        raceIndex[race].raceDuration = _raceDuration;
        assert(race.setupRace(_bettingDuration,_raceDuration));
        RaceDeployed(address(race), race.owner(), _bettingDuration, _raceDuration, now);
        oracleRecoveryQueryId=recoveryController(recoveryDuration);
        recoveryIndex[oracleRecoveryQueryId].raceContract = address(race);
        recoveryIndex[oracleRecoveryQueryId].recoveryNeeded = true;
    }

    function __callback(bytes32 oracleQueryId, string result, bytes proof) {
        require (msg.sender == oraclize_cbAddress());
        if (recoveryIndex[oracleQueryId].recoveryNeeded) {
            Race(address(recoveryIndex[oracleQueryId].raceContract)).recovery();
            recoveryIndex[oracleQueryId].recoveryNeeded = false;
        } else {
            spawnRace(oracleIndex[oracleQueryId].bettingDuration,oracleIndex[oracleQueryId].raceDuration);
            raceController(oracleIndex[oracleQueryId].delay, oracleIndex[oracleQueryId].bettingDuration,oracleIndex[oracleQueryId].raceDuration);
        }
    }

    function raceController(uint256 _delay, uint256 _bettingDuration, uint256 _raceDuration) internal returns(bytes32){
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            bytes32 oracleQueryId;
            oracleQueryId = oraclize_query(_delay, "URL", "", oraclizeGasLimit);
            oracleIndex[oracleQueryId].bettingDuration = _bettingDuration;
            oracleIndex[oracleQueryId].raceDuration = _raceDuration;
            oracleIndex[oracleQueryId].delay = _delay;
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            return oracleQueryId;
        }
    }

    function recoveryController(uint256 delay) internal returns(bytes32){
        if (oraclize_getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            bytes32 oracleRecoveryQueryId;
            oracleRecoveryQueryId = oraclize_query(delay, "URL", "", oraclizeGasLimit);
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            return oracleRecoveryQueryId;
        }
    }

    function initiateRaceSpawning(uint256 _delay, uint256 _bettingDuration, uint256 _raceDuration) external onlyOwner {
        spawnRace(_bettingDuration,_raceDuration);
        raceController(_delay, _bettingDuration, _raceDuration);
    }

    function spawnRaceManual(uint256 _bettingDuration, uint256 _raceDuration) external onlyOwner {
        spawnRace(_bettingDuration,_raceDuration);
    }

    function enableRefund(address _race) external onlyOwner {
        Race raceInstance = Race(_race);
        raceInstance.refund();
    }

    function raceSpawnSwitch(bool _status) external onlyOwner {
        paused=_status;
    }

    function extractFund(uint256 _amount) external onlyOwner {
        require(_amount < this.balance);
        owner.transfer(_amount);
    }
}
