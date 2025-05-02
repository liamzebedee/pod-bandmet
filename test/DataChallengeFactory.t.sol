// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DataChallengeFactory} from "../src/DataChallengeFactory.sol";

contract DataChallengeFactoryTest is Test {
    DataChallengeFactory public fac;

    function setUp() public {
        fac = new DataChallengeFactory();
    }

    function test_setup() public {
        bytes32 commit = keccak256(abi.encodePacked("preimage"));
        uint256 challengeId = fac.setup(commit);
        assertEq(challengeId, 1);

        bytes32 preimage = bytes32("preimage");
        fac.solve(1, preimage);
    }
}
