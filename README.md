# Juristopia - a Multi-World Protocol

Juristopia is a "universe", populated by a collection of worlds, which live on a 3D grid. Each world has a name and description.

## TODOS
* copy JSON ABI into `juristopia/abi/juristopia.json` automatically when `forge` builds

## Smart Contracts
In `sol-contracts` directory. 
  * install dependencies: `npm i`
  * run tests with logs: `forge test --vv`

## Kinode Commands
```
m our@juristopia:juristopia:basilesex.os '{"SetNumber": 55}'
```

### Deploy Solidity Contract
```
forge script --rpc-url http://localhost:8545 script/Deploy.s.sol --broadcast   
```