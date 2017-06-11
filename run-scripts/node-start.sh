#!/bin/bash
set -u
set -e

true ${NETID:?"!"}
true ${BOOTNODE_HASH:?"!"}
true ${BOOTNODE_APPNAME:?"!"}
true ${BOOTNODE_PORT:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}
true ${CF_API:?"!"}
true ${CF_USERNAME:?"!"}
true ${CF_PASSWORD:?"!"}
true ${CF_ORGANIZATION:?"!"}
true ${CF_SPACE:?"!"}
true ${OTHER_NODE_APPNAME:?"!"}
true ${OTHER_NODE_PORT:?"!"}

cf login -a "$CF_API" -u "$CF_USERNAME" -p "$CF_PASSWORD" -o "$CF_ORGANIZATION" -s "$CF_SPACE"

NODE_IP=$(hostname --ip-address)
echo "NODE_IP=$NODE_IP"
BOOTNODE_IP=$(cf ssh $BOOTNODE_APPNAME -c "hostname --ip-address")
echo "BOOTNODE_IP=$BOOTNODE_IP"
OTHER_NODE_IP=$(cf ssh $OTHER_NODE_APPNAME -c "hostname --ip-address")
echo "OTHER_NODE_IP=$OTHER_NODE_IP"

sed -ibak "s|url = .*|url = \"http://$NODE_IP:$NODE_PORT/\"|" $PRIVATE_CONFIG_FILE
sed -ibak "s|port = .*|port = $NODE_PORT|" $PRIVATE_CONFIG_FILE
sed -ibak "s|otherNodeUrls = .*|otherNodeUrls = [\"http://$OTHER_NODE_IP:$OTHER_NODE_PORT/\"]|" $PRIVATE_CONFIG_FILE

constellation-node \
  --verbosity=9 \
  $PRIVATE_CONFIG_FILE \
&

sleep 5

PRIVATE_CONFIG=$PRIVATE_CONFIG_FILE \
  geth \
  --datadir $DATA_DIR \
  --bootnodes enode://$BOOTNODE_HASH@[$BOOTNODE_IP]:$BOOTNODE_PORT \
  --networkid $NETID \
  --rpc \
  --rpcaddr 0.0.0.0 \
  --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum \
  --rpcport $RPC_PORT \
  --port $LISTEN_PORT \
  --verbosity 4 \
;
