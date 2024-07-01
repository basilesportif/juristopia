#!/bin/bash

# Extract the 'abi' field from the source JSON and write it to the target file
jq '.abi' sol-contracts/out/Juristopia.sol/Juristopia.json > juristopia/abi/Juristopia.json

echo "ABI updated successfully."