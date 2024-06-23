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
    uint256 public spawnCostGrowthRate;
    //constant
    mapping(bytes32 => World) public cubeCoordToWorld;
    mapping(bytes32 => uint16) public cubeCoordToDensity;

    constructor(
        int128 _cubeHalfSide,
        uint256 _spawnBaseCost,
        uint256 _spawnCostGrowthRate
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
    ) public pure returns (int256) {
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
    function spawnCost(Point memory p) public view returns (uint256) {
        int128 side = cubeHalfSide * 2;
        require(p.x % side != 0, "x is invalid: on cube edge");
        require(p.y % side != 0, "y is invalid: on cube edge");
        require(p.z % side != 0, "z is invalid: on cube edge");
        Point memory cc = containingCube(p);
        SD59x18 distance = convert(int256(pointDistance(p, cc)));
        SD59x18 cgr = convert(int256(spawnCostGrowthRate));
        SD59x18 cost = convert(int256(spawnBaseCost)).mul(
            distance.mul(cgr).exp()
        );

        bytes32 coord = hashCoords(cc);
        return uint256(convert(cost));
        /*
        // find the cube in the coords
        // calculate how far the coords are from the edge. Take CUBE_SIZE as the edge length
        uint16 density = cubeToDensity[coord];
        return density * density * density;
        */
    }

    function spawnWorld(
        Point memory p,
        string memory name,
        string memory description
    ) public {
        bytes32 coord = hashCoords(p);
        cubeCoordToWorld[coord] = World({name: name, description: description});
        cubeCoordToDensity[coord] += 1;
    }
}
