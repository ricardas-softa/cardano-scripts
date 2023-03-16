#!/bin/sh
# Send all UTXO value, including native tokens, to another wallet
# Usage: send_utxo_value.sh <UTXO> <index> <destination_address>

# Check if arguments are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: send_utxo_value.sh <UTXO> <index> <destination_address>"
    exit 1
fi

UTXO="$1"
INDEX="$2"
DST_ADDRESS="$3"

# Check if source wallet exists
if [ ! -f "payment.addr" ] || [ ! -f "payment.skey" ]; then
    echo "Source wallet does not exist"
    exit 1
fi

# Get protocol parameters
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file protocol.json

# Get UTXO ADA value
VALUE=$(cardano-cli query utxo \
    --address $(cat ${SRC_WALLET}_payment.addr) \
    --mainnet | grep $UTXO | grep $INDEX | awk '{print $3}')

# Get UTXO native tokens value and hash with name
TOKENS=$(cardano-cli query utxo \
    --address $(cat ${SRC_WALLET}_payment.addr) \
    --mainnet | grep $UTXO | grep $INDEX | awk '{print $6,$7}')

# Build transaction
echo "Building transaction..."
cardano-cli transaction build-raw \
    --tx-in $UTXO#$INDEX \
    --tx-out $DST_ADDRESS+$VALUE+"$TOKENS" \
    --fee 0 \
    --out-file tx.raw

# Calculate fee
FEE=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.raw \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --witness-count 1 \
    --mainnet \
    --protocol-params-file protocol.json | awk '{print $1}')

VALUE_AFTER_FEE=$(expr ${VALUE} - ${FEE})

# Build transaction with fee
echo "Building transaction with fee..."
cardano-cli transaction build-raw \
    --tx-in $UTXO#$INDEX \
    --tx-out $DST_ADDRESS+$VALUE_AFTER_FEE+"$TOKENS" \
    --fee $FEE \
    --out-file tx.raw

# Sign transaction
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --mainnet \
    --out-file tx.signed

# Submit transaction
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet

# # Clean up
# rm protocol.json tx.raw tx.signed
