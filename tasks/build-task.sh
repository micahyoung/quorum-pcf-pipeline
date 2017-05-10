#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SRC_DIR=${SRC_DIR:?"!"}
OUTPUT_DIR=${OUTPUT_DIR:?"!"}

pushd $SRC_DIR
  make geth
popd
