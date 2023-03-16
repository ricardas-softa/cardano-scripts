#!/bin/bash
# Script to mint a token in Cardano Mainnet
# Usage: ./mint-token-mainnet.sh <token name> <token amount>

# Check if token name and amount are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./mint-token-mainnet.sh <token name> <token amount>"
    exit 1
fi

# Check script dependencies
if ! command -v cardano-cli &> /dev/null
then
    echo "cardano-cli could not be found"
    exit
fi

if ! command -v xxd &> /dev/null
then
    echo "xxd could not be found"
    exit
fi

tokenname=$(echo -n "$1" | xxd -ps | tr -d '\n')
tokenamount="$2"

# Print info of a token to be minted
echo "Token name: $1"
echo "Token name (hex): $tokenname"
echo "Token amount: $tokenamount"
echo ""

output="0"

# Check if mainnet is running and synced
sync_progress=$(cardano-cli query tip --mainnet | grep "syncProgress" | cut -d ':' -f 2 | tr -d ' "')
if [ "$sync_progress" == "100.00" ]; then
    echo "Mainnet is synced"
else
    echo "Mainnet is not synced"
    exit 1
fi
echo ""

# Check if wallet exists
if [ ! -f "payment.skey" ]; then
    # Creating wallet
    echo "Creating wallet..."
    echo "";
    cardano-cli address key-gen --verification-key-file payment.vkey --signing-key-file payment.skey
    cardano-cli address build --payment-verification-key-file payment.vkey --out-file payment.addr --mainnet
fi

address=$(cat payment.addr)

# Check if wallet has ADA
total=0
balance=$(cardano-cli query utxo --address $address --mainnet | grep "lovelace" | awk '{print $3}')
while read -r line; do
    total=$((total + line))
done <<< "$balance"
echo "Balance: $total"
echo ""
if [ "$total" -lt 2000000 ]; then
    echo "Not enough ADA in wallet"
    echo "Please fund this address: $address"
    exit 1
fi

# Download protocol paremeters
cardano-cli query protocol-parameters --mainnet --out-file protocol.json

# Check if policy folder exists and create it if not
if [ ! -d "policy" ]; then
    mkdir policy
fi

#Check if policy keys exist and create them if not
if [ ! -f "policy/policy.vkey" ]; then
    echo "Creating policy keys..."
    cardano-cli address key-gen --verification-key-file policy/policy.vkey --signing-key-file policy/policy.skey
fi

# Check if policy script exists and delete if it does
if [ -f "policy/policy.script" ]; then
    echo "Deleting old policy script..."
    rm policy/policy.script
fi

# Create policy script
echo "Creating policy script..."
echo "{" > policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script 
echo "  \"type\": \"sig\"" >> policy/policy.script 
echo "}" >> policy/policy.script

# Print policy Script to screen
echo ""
echo "Policy script:"
cat policy/policy.script
echo ""

# Check if policyID exists and delete it if it does
if [ -f "policy/policyID" ]; then
    echo "Deleting old policyID..."
    rm policy/policyID
fi

# Create policyID
echo "Creating policyID..."
cardano-cli transaction policyid --script-file ./policy/policy.script > policy/policyID

# Print policyID to screen
echo ""
echo "PolicyID:"
cat policy/policyID
echo ""

# Find UTXO large enough to use
utxo=$(cardano-cli query utxo --address $address --mainnet | awk '$4 == "lovelace" && NF == 6 && $3 >= 2000000 {print $1, $2, $3}' | head -n 1)
read txhash txix funds <<< $utxo
echo "Selected UTxO: $txhash#$txix"
echo "";

# Parameters for transaction
policyid=$(cat policy/policyID)
fee="300000"

# Check if raw transaction exists and delete it if it does
if [ -f "matx.raw" ]; then
    echo "Deleting old raw transaction..."
    rm matx.raw
fi

# Make raw transaction
if [ ! -f "matx.raw" ]; then
    cardano-cli transaction build-raw \
    --fee $fee \
    --tx-in $txhash#$txix \
    --tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
    --mint "$tokenamount $policyid.$tokenname" \
    --minting-script-file policy/policy.script \
    --out-file matx.raw
 fi

# Check if raw transaction is built
if [ ! -f "matx.raw" ]; then
    echo "Raw transaction could not be built"
    exit 1
fi

# Calculate minimum fee
fee=$(cardano-cli transaction calculate-min-fee --tx-body-file matx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 --mainnet --protocol-params-file protocol.json | cut -d " " -f1)
echo "";
echo "Calculated fee: $fee"
echo "";

# Calculate leftover funds
output=$(expr $funds - $fee)

# Build the transaction
echo "Building transaction..."
cardano-cli transaction build-raw \
--fee $fee  \
--tx-in $txhash#$txix  \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint "$tokenamount $policyid.$tokenname" \
--minting-script-file policy/policy.script \
--out-file matx.raw

# Sign the transaction
echo "Signing transaction..."
cardano-cli transaction sign  \
--signing-key-file payment.skey  \
--signing-key-file policy/policy.skey  \
--mainnet --tx-body-file matx.raw  \
--out-file matx.signed

# Check if transaction is signed
if [ ! -f "matx.signed" ]; then
    echo "Transaction could not be signed"
    exit 1
fi

# Submit the transaction
echo "Submitting transaction..."
cardano-cli transaction submit --tx-file matx.signed --mainnet

# Print info of a token to be minted
echo "Done!"

# Checking if token is minted
echo "Checking if token is minted..."
while ! cardano-cli query utxo --address $address --mainnet | grep -q $tokenname; do
  sleep 5
done
echo "Token is minted!"
# show the wallet
cardano-cli query utxo --address $address --mainnet