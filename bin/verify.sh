#!/usr/bin/env bash
NETWORK=${1?Error: No network provided}


ADDRESS=`jq -r '.address' ./deployments/${NETWORK}/Metador.json`

npx hardhat verify --network $NETWORK $ADDRESS \
    "0x2890bA17EfE978480615e330ecB65333b880928e" \
    "0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA"
