// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Point, Juristopia} from "../src/Juristopia.sol";
//import {UD60x18, ud, convert} from "@prb/math/src/UD60x18.sol";
import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";
import "forge-std/console.sol";

contract JuristopiaTest is Test {
    Juristopia juristopia;

    function setUp() public {
        juristopia = new Juristopia(5);
    }

    function test_ContainingCube() public {
        //points in 3D space
        Point[5] memory inputs = [
            Point({x: 1, y: 1, z: 1}),
            Point({x: -1, y: -1, z: -1}),
            Point({x: 14, y: 14, z: 14}),
            Point({x: -14, y: -14, z: -14}),
            Point({x: 1, y: 1, z: -1})
        ];

        // expected centers of containing cubes
        Point[5] memory expectedOutputs = [
            Point({x: 5, y: 5, z: 5}),
            Point({x: -5, y: -5, z: -5}),
            Point({x: 15, y: 15, z: 15}),
            Point({x: -15, y: -15, z: -15}),
            Point({x: 5, y: 5, z: -5})
        ];

        for (uint i = 0; i < inputs.length; i++) {
            Point memory expected = expectedOutputs[i];
            Point memory result = juristopia.containingCube(inputs[i]);
            assertEq(result.x, expected.x, "Incorrect x for input point");
            assertEq(result.y, expected.y, "Incorrect y for input point");
            assertEq(result.z, expected.z, "Incorrect z for input point");
        }
    }

    function test_PointDistance() public {
        Point memory p1 = Point({x: 1, y: 2, z: -5});
        Point memory p2 = Point({x: 4, y: 6, z: 7});
        int256 distance = juristopia.pointDistance(p1, p2);
        console.logInt(distance);
    }
}
