#!/bin/sh
# Get UTXOs for a wallet
# Usage: get_utxos <wallet_name>
# Example: get_utxos mywallet

# Check if wallet name is provided
if [ -z "$1" ]; then
    wallet_name = "payment";
else
    wallet_name = $1_payment;
fi

# Check if wallet exists
if [ ! -f "$wallet_name.addr" ]; then
    echo "Wallet does not exist"
    exit 1
fi

# Get UTXOs
cardano-cli query utxo \
    --address $(cat $wallet_name.addr) \
    --mainnet