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

echo Creating localnet from localnet.genesis
cp -r $SCRIPT_DIR/localnet.genesis.do_not_modify $SCRIPT_DIR/localnet

# Start the new localnet.
echo Starting localnet process
sui start --network.config $SCRIPT_DIR/localnet/network.yaml >&$SCRIPT_DIR/sui_console.log &

# TODO actively look if running instead of sleep fix amount of time.
sleep 5

# Make sure available in sui envs (ignore errors because might already exist)
echo ========
echo Updating sui client
sui client new-env --alias localnet --rpc http://0.0.0.0:9000 >& /dev/null

# Make local the active network to use for "sui client".
sui client switch --env localnet
sui client switch --address 0x53517c37dca6b7f898f6d98a48756d7645283fa3

# print sui envs to help debugging (if others report problem with this script).
sui client envs
echo ========

# TODO Verify that the localnet is as expected.
echo Listing localnet genesis objects
sui client objects
echo ========
echo Success. You can check the localnet objects with \"sui client object --id \<Object ID\>\"