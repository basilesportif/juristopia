// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Point, Juristopia} from "../src/Juristopia.sol";
//import {UD60x18, ud, convert} from "@prb/math/src/UD60x18.sol";
import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";
import "forge-std/console.sol";

contract JuristopiaTest is Test {
    Juristopia juristopia;
    int128 public constant HALF_SIDE = 5;
    uint256 public constant BASE_COST = 0.1 ether;
    SD59x18 public DENSITY_GROWTH_FACTOR = sd(1.0e18);
    SD59x18 public DISTANCE_GROWTH_FACTOR = sd(0.5e18);

    function setUp() public {
        juristopia = new Juristopia(
            HALF_SIDE,
            BASE_COST,
            DENSITY_GROWTH_FACTOR,
            DISTANCE_GROWTH_FACTOR
        );
    }

    function test_ContainingCube() public view {
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

    function test_PointDistance() public view {
        Point memory p1 = Point({x: 1, y: 2, z: -5});
        Point memory p2 = Point({x: 4, y: 6, z: 7});
        assertEq(juristopia.pointDistance(p1, p2), 13);

        Point memory p3 = Point({x: -1, y: -1, z: 3});
        Point memory p4 = Point({x: 4, y: -10, z: 17});
        assertEq(juristopia.pointDistance(p3, p4), 17);
    }

    function test_SpawnCost() public {
        // 0.738905609893065022
        //0.271828182845904523
        int32 density1 = 0;
        int256 distance1 = 0;
        assertEq(juristopia.spawnCost(density1, distance1), 0.1 ether);

        int32 density2 = 2;
        int256 distance2 = 0;
        assertEq(
            juristopia.spawnCost(density2, distance2),
            0.738905609893065022 ether
        );

        int32 density3 = 0;
        int256 distance3 = 2;
        assertEq(
            juristopia.spawnCost(density3, distance3),
            .271828182845904523 ether
        );

        int32 density4 = 2;
        int256 distance4 = 2;
        assertEq(
            juristopia.spawnCost(density4, distance4),
            2.008553692318766772 ether
        );
    }

    function test_SpawnWorld() public {
        Point memory testPoint = Point({x: 7, y: 8, z: 9});
        string memory testName = "Test World";
        string memory testDescription = "A test world description";

        // Get the containing cube and its initial density
        Point memory containingCube = juristopia.containingCube(testPoint);
        bytes32 cubeCoord = juristopia.hashCoords(containingCube);
        int32 initialDensity = juristopia.cubeCoordToDensity(cubeCoord);

        // Calculate spawn cost
        uint256 spawnCost = juristopia.spawnCost(
            initialDensity,
            juristopia.pointDistance(testPoint, containingCube)
        );

        // Spawn the world
        juristopia.spawnWorld{value: spawnCost}(
            testPoint,
            testName,
            testDescription
        );

        // Check if the world exists at the given coordinates
        bytes32 worldCoord = juristopia.hashCoords(testPoint);
        (string memory name, string memory description, , ) = juristopia
            .coordToWorld(worldCoord);
        assertEq(name, testName, "World name does not match");
        assertEq(
            description,
            testDescription,
            "World description does not match"
        );

        // Check if the density in the containing cube has incremented
        int32 newDensity = juristopia.cubeCoordToDensity(cubeCoord);
        assertEq(
            newDensity,
            initialDensity + 1,
            "Density did not increment correctly"
        );

        int256 distance = juristopia.pointDistance(testPoint, containingCube);
        uint256 secondSpawnCost = juristopia.spawnCost(newDensity, distance);

        vm.expectRevert("World already exists");
        juristopia.spawnWorld{value: secondSpawnCost}(
            testPoint,
            "new name",
            "new description"
        );
    }

    function test_BadSpawnWorlds() public {
        Point memory testPoint = Point({x: 7, y: 8, z: 9});
        string memory testName = "Test World";
        string memory testDescription = "A test world description";

        // Get the containing cube and its initial density
        Point memory containingCube = juristopia.containingCube(testPoint);
        bytes32 cubeCoord = juristopia.hashCoords(containingCube);
        int32 initialDensity = juristopia.cubeCoordToDensity(cubeCoord);

        // Calculate spawn cost
        uint256 spawnCost = juristopia.spawnCost(
            initialDensity,
            juristopia.pointDistance(testPoint, containingCube)
        );
        // Spawn the world
        juristopia.spawnWorld{value: spawnCost}(
            testPoint,
            testName,
            testDescription
        );

        spawnCost = juristopia.spawnCost(
            initialDensity + 1,
            juristopia.pointDistance(testPoint, containingCube)
        );

        // Attempt to spawn another world at the same coordinates
        vm.expectRevert("World already exists");
        juristopia.spawnWorld{value: spawnCost}(
            testPoint,
            "Another World",
            "This should fail"
        );

        Point memory testPoint2 = Point({x: 2, y: 2, z: 2});
        uint256 spawnCost2 = juristopia.spawnCost(
            initialDensity + 1,
            juristopia.pointDistance(testPoint2, containingCube)
        );
        // Attempt to spawn a world with insufficient ETH
        vm.expectRevert("Not enough ETH to spawn this world");
        juristopia.spawnWorld{value: spawnCost2 - 1}(
            testPoint2,
            "Underfunded World",
            "This should also fail"
        );

        // Attempt to spawn a world with an empty name
        vm.expectRevert("Name cannot be empty");
        juristopia.spawnWorld{value: spawnCost2}(
            testPoint2,
            "",
            "This should fail due to empty name"
        );

        // Attempt to spawn a world with an empty description
        vm.expectRevert("Description cannot be empty");
        juristopia.spawnWorld{value: spawnCost2}(testPoint2, "Valid Name", "");

        // Attempt to spawn a world with a name that's too long
        vm.expectRevert("Name must be 32 characters or less");
        juristopia.spawnWorld{value: spawnCost2}(
            testPoint2,
            "This name is way too long and should cause an error",
            "Valid description"
        );

        // Attempt to spawn a world on a cube edge
        vm.expectRevert("x is invalid: on cube edge");
        juristopia.spawnWorld{value: spawnCost2}(
            Point({x: int128(HALF_SIDE * 2), y: 22, z: 23}),
            "Edge World",
            "This should fail due to being on a cube edge"
        );
    }
}
