#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SRC_DIR=${SRC_DIR:?"!"}
PIPELINE_DIR=${PIPELINE_DIR:?"!"}
OUTPUT_DIR=${OUTPUT_DIR:?"!"}

pushd $SRC_DIR
  make geth
popd

cp $SRC_DIR/build/bin/geth $OUTPUT_DIR/geth
cp $PIPELINE_DIR/manifest.yml $OUTPUT_DIR/manifest.yml
