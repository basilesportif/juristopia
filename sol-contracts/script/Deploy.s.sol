// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console, VmSafe} from "forge-std/Script.sol";
import {Juristopia} from "../src/Juristopia.sol";
import {SD59x18, sd, convert} from "@prb/math/src/SD59x18.sol";

contract DeployScript is Script {
    address public constant GOD = address(9);
    int128 public constant HALF_SIDE = 5;
    uint256 public constant BASE_COST = 0.1 ether;
    SD59x18 public DENSITY_GROWTH_FACTOR = sd(1.0e18);
    SD59x18 public DISTANCE_GROWTH_FACTOR = sd(0.5e18);
    uint256 public PORTAL_BASE_COST = 0.1 ether;
    SD59x18 public PORTAL_DISTANCE_GROWTH_FACTOR = sd(0.1e18);

    function setUp() public {}

    function run() public {
        VmSafe.Wallet memory wallet = vm.createWallet(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        );
        vm.startBroadcast(wallet.privateKey);

        Juristopia juristopia = new Juristopia(
            GOD,
            HALF_SIDE,
            BASE_COST,
            DENSITY_GROWTH_FACTOR,
            DISTANCE_GROWTH_FACTOR,
            PORTAL_BASE_COST,
            PORTAL_DISTANCE_GROWTH_FACTOR
        );
        console.log("Juristopia deployed at address: ", address(juristopia));
        vm.stopBroadcast();
    }
}
