#!/bin/bash
set -u
set -e

true ${BOOTNODE_IP:?"!"}
true ${BOOTNODE_KEYHEX:?"!"}
true ${BOOTNODE_ENODE:?"!"}

PRIVATE_CONFIG=tm1.conf geth \
  --exec 'loadScript("script1.js")' attach ipc:qdata/dd1/geth.ipc
