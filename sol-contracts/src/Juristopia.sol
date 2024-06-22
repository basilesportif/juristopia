// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";

struct World {
    string name;
    string description;
}

contract Juristopia {
    uint256 public constant CUBE_SIZE = 10;
    //constant
    mapping(bytes32 => World) public coordToWorld;
    mapping(bytes32 => uint16) public cubeToDensity;

    function hashCoords(int x, int y, int z) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(x, y, z));
    }

    function spawnCost(int x, int y, int z) public view returns (uint256) {
        bytes32 coord = hashCoords(x, y, z);
        uint16 density = cubeToDensity[coord];
        return density * density * density;
    }

    function spawnWorld(
        int x,
        int y,
        int z,
        string memory name,
        string memory description
    ) public {
        bytes32 coord = hashCoords(x, y, z);
        coordToWorld[coord] = World({name: name, description: description});
        cubeToDensity[coord] += 1;
    }
}
