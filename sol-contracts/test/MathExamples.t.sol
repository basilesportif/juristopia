// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";
import "forge-std/console.sol";

contract MathExamplesTest is Test {
    function test_MathLibrary() public view {
        /*
        UD60x18 n = convert(2);
        UD60x18 e2 = n.exp();
        UD60x18 cost = e2.mul(convert(1 ether));
        console.log("e: %i", convert(e2));
                assertEq(convert(e2), 7);
        assertEq(convert(cost), 7389056098930650223);
        */
        int128 y = -12;
        int128 y2 = y * y;
        SD59x18 y2Sd = convert(y2);
        SD59x18 y2SdSqrt = y2Sd.sqrt();
        int256 y2SdSqrtInt = convert(y2SdSqrt);
        console.logInt(y2SdSqrtInt);
    }
}
