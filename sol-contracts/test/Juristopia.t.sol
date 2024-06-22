// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Point, Juristopia} from "../src/Juristopia.sol";
import {UD60x18, ud, convert} from "@prb/math/src/UD60x18.sol";
import "forge-std/console.sol";

contract JuristopiaTest is Test {
    Juristopia juristopia;

    function setUp() public {
        juristopia = new Juristopia(5);
    }

    function test_ContainingCube() public {
        // Input test cases
        int128[3][5] memory inputs = [
            [int128(1), int128(1), int128(1)],
            [int128(-1), int128(-1), int128(-1)],
            [int128(14), int128(14), int128(14)],
            [int128(-14), int128(-14), int128(-14)],
            [int128(1), int128(1), int128(-1)]
        ];

        // Expected output test cases
        int128[3][5] memory expectedOutputs = [
            [int128(5), int128(5), int128(5)],
            [int128(-5), int128(-5), int128(-5)],
            [int128(15), int128(15), int128(15)],
            [int128(-15), int128(-15), int128(-15)],
            [int128(5), int128(5), int128(-5)]
        ];

        for (uint i = 0; i < inputs.length; i++) {
            Point memory input = Point({
                x: inputs[i][0],
                y: inputs[i][1],
                z: inputs[i][2]
            });
            Point memory expected = Point({
                x: expectedOutputs[i][0],
                y: expectedOutputs[i][1],
                z: expectedOutputs[i][2]
            });
            Point memory result = juristopia.containingCube(input);

            assertEq(result.x, expected.x, "Incorrect x for input point");
            assertEq(result.y, expected.y, "Incorrect y for input point");
            assertEq(result.z, expected.z, "Incorrect z for input point");
        }
    }

    /*
test notes
- we want to multiply a wei cost by this 
*/
    function test_MathLibrary() public view {
        UD60x18 n = convert(2);
        UD60x18 e2 = n.exp();
        UD60x18 cost = e2.mul(convert(1 ether));
        console.log("e: %i", convert(e2));
        int64 y = 12;
        int64 modulo = -y + 10;
        console.logInt(modulo);
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
