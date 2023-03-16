#!/bin/sh
# Generate a new wallet
# Usage: gen_wallet <wallet_name>
# Example: gen_wallet mywallet

# Check if wallet name is provided
if [ -z "$1" ]; then
    payment_name = "payment";
    stake_name = "stake";
else
    payment_name = $1_payment;
    stake_name = $1_stake;
fi

# Check if wallet already exists
if [ -f "$1_payment.addr" ]; then
    echo "Wallet already exists"
    exit 1
fi

# Generate wallet
echo "Generating wallet '$payment_name'..."

cardano-cli address key-gen \
    --verification-key-file $payment_name.vkey \
    --signing-key-file $payment_name.skey \

cardano-cli stake-address key-gen \
    --verification-key-file $stake_name.vkey \
    --signing-key-file $stake_name.skey

cardano-cli address build \
    --payment-verification-key-file $payment_name.vkey \
    --stake-verification-key-file $stake_name.vkey \
    --out-file $payment_name.addr \
    --mainnet

cardano-cli stake-address build \
    --stake-verification-key-file $stake_name.vkey \
    --out-file $stake_name.addr \
    --mainnet

echo "Wallet generated successfully!"

if [ -n "$1" ]; then
  echo $(ls . | grep "$1")
else
  echo $(ls . | grep -e "payment" -e "stake")
fi
