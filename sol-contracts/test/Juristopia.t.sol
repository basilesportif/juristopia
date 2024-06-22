// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Juristopia} from "../src/Juristopia.sol";
import {UD60x18, ud, convert} from "@prb/math/src/UD60x18.sol";
import "forge-std/console.sol";

contract JuristopiaTest is Test {
    Juristopia juristopia;

    function setUp() public {
        juristopia = new Juristopia();
    }

    function test_Exponent() public {
        UD60x18 n = ud(2.0e18);
        UD60x18 e = juristopia.exponent(n);
        console.log("e: %i", convert(e));
        assertEq(convert(e), 7);
    }

    /*
    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
    */
}
