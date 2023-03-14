# cardano-scripts
Convenience scripts for doing things with cardano-cli.

## Minting bash scripts

`mint-token-mainnet.sh` script is for Cardano Mainnet

`mint-token.sh` script is for Cardano Preprod Testnet

You can clone the repo and run these scripts like so:
`./mint-token-mainnet.sh <token-name> <token-quantity>`

For example:
`./mint-token-mainnet.sh "MyToken" 10000`

Both scripts will automatically create a wallet if it doesn't exist as `payment.skey` in working directory.

It will show its address for you to fund.

Script can be run again after No Funds error or any other problem.
