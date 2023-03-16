# cardano-scripts
Convenience scripts for doing things with cardano-cli.

# Minting bash scripts

`mint-token-mainnet.sh` script is for Cardano Mainnet

`mint-token.sh` script is for Cardano Preprod Testnet

## Mint Token on Cardano Mainnet

This repository contains a Bash script to mint a token on the Cardano Mainnet.

## Usage

```bash
./mint-token-mainnet.sh <token name> <token amount>

# Example
./mint-token-mainnet.sh "MyToken" 10000
```
Both scripts will automatically create a wallet if it doesn't exist as `payment.skey` in working directory.

It will show its address for you to fund.

Script can be run again after No Funds error or any other problem.

## Prerequisites
- `cardano-cli` installed and in your `PATH`
- `xxd` command available

## Script Workflow

The script performs the following steps to mint a token on the Cardano Mainnet:

1. **Check arguments**: Ensure that the required arguments (token name and token amount) are provided.
2. **Check dependencies**: Verify that `cardano-cli` and `xxd` are installed and accessible in your PATH.
3. **Sync preprod**: Confirm that the preprod is synchronized.
4. **Create wallet**: Generate a new wallet if it doesn't already exist.
5. **Check wallet balance**: Ensure that the wallet has enough ADA to cover transaction fees.
6. **Download protocol parameters**: Retrieve the protocol parameters.
7. **Generate policy keys**: Create policy keys if they don't exist.
8. **Create policy script**: Generate the policy script.
9. **Create policyID**: Produce the policyID.
10. **Select UTxO**: Choose a UTxO with sufficient ADA for the transaction.
11. **Build and sign transaction**: Construct the transaction and sign it with the appropriate keys.
12. **Submit transaction**: Send the signed transaction to the Cardano network.
13. **Check token minting**: Verify that the token has been minted successfully.
14. **Show wallet details**: Display the wallet's current state.

# Other bash scripts

## Generate a New Cardano Wallet

This is a shell script to generate a new Cardano wallet on the Mainnet.

## Usage

```bash
./gen_wallet.sh <wallet_name>

# Example
./gen_wallet.sh mywallet
```

## Get UTXOs for a Cardano Wallet

This is a shell script to get UTXOs (Unspent Transaction Outputs) for a Cardano wallet on the Mainnet.

## Usage

```bash
./get_utxos.sh <wallet_name>

# Example
./get_utxos.sh mywallet
```

## Recover a Cardano Wallet

This repository contains a shell script to recover a Cardano wallet on the Mainnet using a recovery phrase.

## Usage

```bash
recover_wallet <wallet_name> <recovery_phrase>

# Example
recover_wallet mywallet "word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12 word13 word14 word15 word16 word17 word18 word19 word20 word21 word22 word23 word24"
```
