// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";

/**
 * @title World
 * @dev Represents a world in the Juristopia universe
 * @notice This struct contains all the necessary information to define a world
 */
struct World {
    /**
     * @dev The name of the world
     * @notice Must be non-empty and 32 characters or less
     */
    string name;
    /**
     * @dev A description of the world
     * @notice Must be non-empty
     */
    string description;
    /**
     * @dev The 3D coordinates of the world's location
     */
    Point location;
    /**
     * @dev The center coordinates of the cube containing this world
     */
    Point containingCube;
    /**
     * @dev A hash commitment for world state and ZK transition function
     */
    bytes32 commitmentHash;
}
struct Point {
    int128 x;
    int128 y;
    int128 z;
}

struct Portal {
    Point world1;
    Point world2;
}

contract Juristopia {
    address public god;
    int128 public cubeHalfSide;
    uint256 public spawnBaseCost;
    SD59x18 public spawnDensityGrowthFactor;
    SD59x18 public spawnDistanceGrowthFactor;
    uint256 public portalBaseCost;
    SD59x18 public portalDistanceGrowthFactor;

    mapping(bytes32 => World) public coordToWorld;
    mapping(bytes32 => int32) public cubeCoordToDensity;
    mapping(bytes32 => mapping(bytes32 => bool)) public portalExists;

    constructor(
        address _god,
        int128 _cubeHalfSide,
        uint256 _spawnBaseCost,
        SD59x18 _spawnDensityGrowthFactor,
        SD59x18 _spawnDistanceGrowthFactor,
        uint256 _portalBaseCost,
        SD59x18 _portalDistanceGrowthFactor
    ) {
        god = _god;
        cubeHalfSide = _cubeHalfSide;
        spawnBaseCost = _spawnBaseCost;
        spawnDensityGrowthFactor = _spawnDensityGrowthFactor;
        spawnDistanceGrowthFactor = _spawnDistanceGrowthFactor;
        portalBaseCost = _portalBaseCost;
        portalDistanceGrowthFactor = _portalDistanceGrowthFactor;
    }

    modifier onlyGod() {
        require(msg.sender == god, "Only God can perform this action");
        _;
    }

    /**
     * @notice Hashes the coordinates of a given point in 3D space
     * @dev Uses keccak256 to hash the packed encoding of the x, y, and z coordinates
     * @param p The Point struct containing the coordinates to be hashed
     * @return bytes32 The resulting hash of the coordinates
     */
    function hashCoords(Point memory p) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(p.x, p.y, p.z));
    }

    /**
     * @notice Calculates the rounded 3D Euclidean distance between two points
     * @dev This function uses the Pythagorean theorem in 3D space to calculate the distance.
     * The result is rounded to the nearest integer.
     * @param p1 The first point in 3D space
     * @param p2 The second point in 3D space
     * @return The rounded integer distance between the two points
     */
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

    /**
     * @notice Calculates the center coordinates of the cube containing the given point
     * @dev This function determines the cube in which a given point resides and returns its center coordinates.
     * The universe is divided into cubes with side length equal to 2 * cubeHalfSide.
     * @param p The input point for which to find the containing cube
     * @return Point The center coordinates of the containing cube
     */
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
    /**
     * @notice Calculates the cost to spawn a new world
     * @dev The cost is calculated based on the density of the containing cube and the distance from its center.
     * The formula used is: cost = spawnBaseCost * e^(density * spawnDensityGrowthFactor + distance * spawnDistanceGrowthFactor)
     * @param _density The current density of the containing cube
     * @param _distanceFromCenter The distance from the center of the containing cube to the spawn point
     * @return The cost in wei to spawn a new world
     */
    function spawnCost(
        int32 _density,
        int256 _distanceFromCenter
    ) public view returns (uint256) {
        SD59x18 density = convert(int256(_density));
        SD59x18 distance = convert(int256(_distanceFromCenter));
        SD59x18 densityFactor = density.mul(spawnDensityGrowthFactor);
        SD59x18 distanceFactor = distance.mul(spawnDistanceGrowthFactor);
        SD59x18 eToTheRT = (distanceFactor.add(densityFactor)).exp();
        SD59x18 cost = convert(int256(spawnBaseCost)).mul(eToTheRT);
        return uint256(convert(cost));
    }
    /**
     * @notice Spawns a new world at the given coordinates
     * @dev This function creates a new world in the Juristopia universe. It requires payment in ETH,
     * with the cost calculated based on the density of the containing cube and the distance from its center.
     * @param p The 3D coordinates where the world will be spawned
     * @param name The name of the new world (must be non-empty and 32 characters or less)
     * @param description A description of the new world (must be non-empty)
     * @custom:throws "Name cannot be empty" if the name is empty
     * @custom:throws "Description cannot be empty" if the description is empty
     * @custom:throws "Name must be 32 characters or less" if the name exceeds 32 characters
     * @custom:throws "x is invalid: on cube edge" if the x coordinate is on a cube edge
     * @custom:throws "y is invalid: on cube edge" if the y coordinate is on a cube edge
     * @custom:throws "z is invalid: on cube edge" if the z coordinate is on a cube edge
     * @custom:throws "Not enough ETH to spawn this world" if the sent ETH is less than the required cost
     * @custom:throws "World already exists" if a world already exists at the given coordinates
     */
    function spawnWorld(
        Point memory p,
        string memory name,
        string memory description,
        bytes32 commitmentHash
    ) public payable {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(name).length <= 32, "Name must be 32 characters or less");
        int128 side = cubeHalfSide * 2;
        require(p.x % side != 0, "x is invalid: on cube edge");
        require(p.y % side != 0, "y is invalid: on cube edge");
        require(p.z % side != 0, "z is invalid: on cube edge");
        Point memory cc = containingCube(p);
        bytes32 worldCoord = hashCoords(p);
        bytes32 cubeCoord = hashCoords(cc);
        int32 density = cubeCoordToDensity[cubeCoord];
        uint256 cost = spawnCost(density, pointDistance(p, cc));

        require(msg.value >= cost, "Not enough ETH to spawn this world");
        require(
            bytes(coordToWorld[worldCoord].name).length == 0,
            "World already exists"
        );

        coordToWorld[worldCoord] = World({
            name: name,
            description: description,
            location: p,
            containingCube: cc,
            commitmentHash: commitmentHash
        });
        cubeCoordToDensity[cubeCoord] += 1;
    }

    function createPortalCost(int256 distance) public view returns (uint256) {
        SD59x18 cost = convert(int256(portalBaseCost)).mul(
            convert(distance).mul(portalDistanceGrowthFactor).exp()
        );
        return uint256(convert(cost));
    }

    function createPortal(
        Point memory p1,
        Point memory p2
    ) public payable onlyGod {
        require(
            bytes(coordToWorld[hashCoords(p1)].name).length > 0,
            "World1 does not exist"
        );
        require(
            bytes(coordToWorld[hashCoords(p2)].name).length > 0,
            "World2 does not exist"
        );
        require(
            msg.value >= createPortalCost(pointDistance(p1, p2)),
            "Not enough ETH to create portal"
        );
        // get the commitment hashes

        // Update portal maps
        bytes32 worldCoord1 = hashCoords(p1);
        bytes32 worldCoord2 = hashCoords(p2);

        // Create bidirectional portal
        portalExists[worldCoord1][worldCoord2] = true;
        portalExists[worldCoord2][worldCoord1] = true;
    }
}
