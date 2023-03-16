#!/bin/sh
# Recover a wallet
# Usage: recover_wallet <wallet_name> <recovery_phrase>
# Example: recover_wallet mywallet "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12 word13 word14 word15 word16 word17 word18 word19 word20 word21 word22 word23 word24"

# Check if wallet name is provided
if [ -z "$1" ]; then
    echo "Usage: recover_wallet <wallet_name> <recovery_phrase>"
    exit 1
fi

# Check if wallet already exists
if [ -f "$1_payment.addr" ]; then
    echo "Wallet already exists"
    exit 1
fi

# Check if recovery phrase is provided
if [ -z "$2" ]; then
    echo "Usage: recover_wallet <wallet_name> <recovery_phrase>"
    exit 1
fi

# Recover wallet
echo "Recovering wallet '$1'..."
echo $2 | cardano-wallet key from-recovery-phrase Shelley > $1.root.prv
cardano-wallet key child 1852H/1815H/0H/0/0 < $1.root.prv > $1_payment.prv
cardano-wallet key public --without-chain-code < $1_payment.prv > $1_payment.pub
# Generate payment keys
cardano-cli key convert-cardano-address-key --shelley-payment-key \
                                            --signing-key-file $1_payment.prv \
                                            --out-file $1_payment.skey
cardano-cli key verification-key --signing-key-file $1_payment.skey \
                                 --verification-key-file $1_payment.vkey
# Generate stake keys
cardano-wallet key child 1852H/1815H/0H/2/0 < $1.root.prv > $1_stake.prv
cardano-wallet key public --without-chain-code < $1_stake.prv > $1_stake.pub
cardano-cli key convert-cardano-address-key --shelley-stake-key \
                                            --signing-key-file $1_stake.prv \
                                            --out-file $1_stake.skey
cardano-cli key verification-key --signing-key-file $1_stake.skey \
                                    --verification-key-file $1_stake.vkey
# Generate payment address
cardano-cli address build --payment-verification-key $(cat $1_payment.pub) \
                          --stake-verification-key $(cat $1_stake.pub) \
                          --out-file $1_payment.addr \
                          --mainnet
# Generate stake address
cardano-cli stake-address build --stake-verification-key-file $1_stake.pub \
                                --out-file $1_stake.addr \
                                --mainnet

# Clean up
rm $1.root.prv $1_payment.prv $1_payment.pub $1_stake.prv $1_stake.pub

echo "Wallet recovered successfully!"
echo $(ls . | grep $1_)
