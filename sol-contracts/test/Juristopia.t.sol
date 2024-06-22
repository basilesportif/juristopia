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

    /*
test notes
- we want to multiply a wei cost by this 
*/
    function test_Exponent() public {
        UD60x18 n = convert(2);
        UD60x18 e2 = n.exp();
        UD60x18 cost = e2.mul(convert(1 ether));
        console.log("e: %i", convert(e2));
        assertEq(convert(e2), 7);
        assertEq(convert(cost), 7389056098930650223);
    }

    /*
    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
    */
}
