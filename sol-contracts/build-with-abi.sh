#!/bin/bash

forge build
# Extract the 'abi' field from the source JSON and write it to the target file
jq '.abi' out/Juristopia.sol/Juristopia.json > ../juristopia/abi/Juristopia.json

echo "ABI updated successfully."