// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct DataChallenge {
    uint256 id;
    uint256 startTime;
    uint256 endTime;
    bytes32 commit;
    bytes32 seed;
    address challenger;
    address solver;
}

error ChallengeClosed();
error ChallengeNoExist();
error SolutionIncorrect();

event ChallengeSetup(uint256 id);
event ChallengeSolved(uint256 indexed id, uint256 startTime, uint256 endTime, address indexed solver);

function isSolved(DataChallenge memory _d) pure returns (bool) {
    return _d.endTime != 0;
}

function preimageCheck(bytes32 commit, bytes32 preimage, bytes32 seed) pure returns (bool) {
    // Check H(preimage) == commit.
    // For now, this is just mocked to true.
    commit; preimage; seed;
    return true;
}

function getReward(uint256 maxClaimDuration, uint256 startTime, uint256 endTime) pure {
    // d = end - start
    // factor = 1 - (min(d, maxClaimDuration) / maxClaimDuration)
    // reward = baseReward * factor
    // 
    // Intuition:
    // - the latency (d) is end time minus start time
    // - the reward is a baseReward, scaled according to a factor
    // - we incent fast submissions by the reward
    // - the faster you submit, the bigger the reward
    // - use an exponential function so reward is nonlinearly bigger for faster solutions?
    // - cap the maximum duration, so that any solutions above this receive 0 baseReward (but maybe a fixed reward).
}

contract DataChallengeFactory {
    // Storage.
    mapping (uint256 => DataChallenge) public challenges;
    uint256 public challengeCount = 0;
    uint256 public maxClaimDurationMillis = 3000;

    // 
    // Methods.
    // 

    function setup(
        bytes32 challengeCommit
    ) external returns (uint256) {
        // Generate challenge ID.
        challengeCount += 1;
        uint256 id = challengeCount;

        // Log start time.
        uint256 startTime = block.timestamp;

        // Create challenge.
        DataChallenge memory chal = DataChallenge({
            id: id,
            startTime: startTime,
            endTime: 0,
            commit: challengeCommit,
            seed: blockhash(block.number),
            challenger: msg.sender,
            solver: address(0)
        });
        challenges[id] = chal;
        
        // Emit event.
        emit ChallengeSetup(id);

        return id;
    }

    function solve(
        uint256 challengeId,
        bytes32 challengePreimage
    ) external {
        // Load challenge.
        DataChallenge storage chal = challenges[challengeId];
        
        // Check conditions.
        if(isSolved(chal)) { revert ChallengeClosed(); }
        if(chal.startTime == 0) { revert ChallengeNoExist(); }

        // Do the main check.
        bool success = preimageCheck(chal.commit, challengePreimage, chal.seed);
        if(!success) revert SolutionIncorrect();

        // Set solution time.
        chal.endTime = block.timestamp;
        chal.solver = msg.sender;

        // Set solved.
        emit ChallengeSolved(challengeId, chal.startTime, chal.endTime, chal.solver);
    }
    
}
