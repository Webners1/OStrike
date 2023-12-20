# HOW TO USE:
# Run the following shell script using: KEY=ur_keeeeey ./etherscan_verify.sh

#!/bin/bash

etherscanKey=WKC1YZXG13SBDIMCT9UBAU9SP87IGKPQYR

echo "Using the current etherscan key: ${etherscanKey}" 

$(npm bin)/hardhat etherscan-verify --api-key $etherscanKey