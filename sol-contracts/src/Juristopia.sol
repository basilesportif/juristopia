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
    int128 public halfSide;
    uint256 public spawnBaseCost;
    //constant
    mapping(bytes32 => World) public coordToWorld;
    mapping(bytes32 => uint16) public cubeToDensity;

    constructor(int128 _halfSide) {
        spawnBaseCost = 0.1 ether;
        halfSide = _halfSide;
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
        int128 SIDE = halfSide * 2;
        int128 x = p.x >= 0 ? p.x : -p.x;
        int128 y = p.y >= 0 ? p.y : -p.y;
        int128 z = p.z >= 0 ? p.z : -p.z;
        x = x - (x % SIDE) + halfSide;
        y = y - (y % SIDE) + halfSide;
        z = z - (z % SIDE) + halfSide;
        return
            Point({
                x: p.x >= 0 ? x : -x,
                y: p.y >= 0 ? y : -y,
                z: p.z >= 0 ? z : -z
            });
    }

    // need 3D distance from the cube center to the point
    // cost increases exponentially with distance
    function spawnCost(Point memory p) public view returns (uint256) {
        int128 SIDE = halfSide * 2;
        require(p.x % SIDE != 0, "x is invalid: on cube edge");
        require(p.y % SIDE != 0, "y is invalid: on cube edge");
        require(p.z % SIDE != 0, "z is invalid: on cube edge");
        Point memory cc = containingCube(p);
        bytes32 coord = hashCoords(cc);
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
        coordToWorld[coord] = World({name: name, description: description});
        cubeToDensity[coord] += 1;
    }
}
