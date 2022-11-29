#!/bin/bash

# Initialize and start a Sui local network.
#
# Warning:
#   If there is an existing local network, it will be deleted
#   and replaced with a fresh installation.
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#TODO Make this conditional of detecting running.
#TODO Make this more specific to localnet instead of blind target "sui"
sudo skill -9 pidof sui

# TODO Make this conditional of detecting exists.
echo Removing existing localnet
rm -rf $SCRIPT_DIR/localnet

echo Initializing localnet
mkdir $SCRIPT_DIR/localnet
sui genesis --working-dir $SCRIPT_DIR/localnet

# Start the new local network.
sui start --network.config $SCRIPT_DIR/localnet/network.yaml >&$SCRIPT_DIR/sui_console.log &
sleep 3

# Make sure available in sui envs (ignore errors because might already exist)
sui client new-env --alias localnet --rpc http://0.0.0.0:9000 >& /dev/null

# Make local the active network to use for "sui client".
sui client switch --env localnet

# print sui envs for user convenience and show localnet (hopefully being active).
sui client envs
