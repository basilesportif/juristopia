// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";

struct World {
    string name;
    string description;
}

struct Point {
    int128 x;
    int128 y;
    int128 z;
}

contract Juristopia {
    int128 public cubeHalfSide;
    uint256 public spawnBaseCost;
    SD59x18 public spawnCostGrowthRate;
    //constant
    mapping(bytes32 => World) public cubeCoordToWorld;
    mapping(bytes32 => int32) public cubeCoordToDensity;

    constructor(
        int128 _cubeHalfSide,
        uint256 _spawnBaseCost,
        SD59x18 _spawnCostGrowthRate
    ) {
        cubeHalfSide = _cubeHalfSide;
        spawnBaseCost = _spawnBaseCost;
        spawnCostGrowthRate = _spawnCostGrowthRate;
    }

    function hashCoords(Point memory p) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(p.x, p.y, p.z));
    }

    /** @return the rounded 3D distance between two points */
    function pointDistance(
        Point memory p1,
        Point memory p2
    ) public view returns (int256) {
        int128 squareSum = (p1.x - p2.x) *
            (p1.x - p2.x) +
            (p1.y - p2.y) *
            (p1.y - p2.y) +
            (p1.z - p2.z) *
            (p1.z - p2.z);
        return convert(convert(squareSum).sqrt());
    }

    function containingCube(Point memory p) public view returns (Point memory) {
        int128 side = cubeHalfSide * 2;
        int128 absX = p.x >= 0 ? p.x : -p.x;
        int128 absY = p.y >= 0 ? p.y : -p.y;
        int128 absZ = p.z >= 0 ? p.z : -p.z;
        absX = absX - (absX % side) + cubeHalfSide;
        absY = absY - (absY % side) + cubeHalfSide;
        absZ = absZ - (absZ % side) + cubeHalfSide;
        return
            Point({
                x: p.x >= 0 ? absX : -absX,
                y: p.y >= 0 ? absY : -absY,
                z: p.z >= 0 ? absZ : -absZ
            });
    }

    // need 3D distance from the cube center to the point
    // cost increases exponentially with distance
    function spawnCost(
        int256 _distanceFromCenter,
        int32 _density
    ) public view returns (uint256) {
        SD59x18 density = convert(int256(_density));
        SD59x18 distance = convert(int256(_distanceFromCenter));
        SD59x18 distanceAndDensity = distance.add(density);
        SD59x18 cost = convert(int256(spawnBaseCost)).mul(
            distanceAndDensity.mul(spawnCostGrowthRate).exp()
        );
        return uint256(convert(cost));
    }

    function spawnWorld(
        Point memory p,
        string memory name,
        string memory description
    ) public {
        int128 side = cubeHalfSide * 2;
        require(p.x % side != 0, "x is invalid: on cube edge");
        require(p.y % side != 0, "y is invalid: on cube edge");
        require(p.z % side != 0, "z is invalid: on cube edge");
        Point memory cc = containingCube(p);
        bytes32 coord = hashCoords(p);
        int32 density = cubeCoordToDensity[coord];
        uint256 cost = spawnCost(pointDistance(p, cc), density);
        cubeCoordToWorld[coord] = World({name: name, description: description});
        cubeCoordToDensity[coord] += 1;
    }
}
