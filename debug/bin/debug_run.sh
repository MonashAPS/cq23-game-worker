#!/bin/bash

# Creates a test image based on the server_base dockerfile and runs the server + two clients with that image.

# shellcheck disable=SC2164
WORKER_DIR="$( dirname $( dirname "$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" ))"
BIN_DIR="${WORKER_DIR}/bin"
DOCKERFILES_DIR="${WORKER_DIR}/dockerfiles"
BASE_DIR="$(dirname $WORKER_DIR)"
GCS_DIR="$BASE_DIR/$4"

SERVER_TARGET_IMAGE=$1
SERVER_DIR="$BASE_DIR/$SERVER_TARGET_IMAGE"

CLIENT1_TARGET_IMAGE=$2
CLIENT1_DIR="$BASE_DIR/$CLIENT1_TARGET_IMAGE"

CLIENT2_TARGET_IMAGE=$3
CLIENT2_DIR="$BASE_DIR/$CLIENT2_TARGET_IMAGE"

cd "$SERVER_DIR" || exit
docker build . -f Dockerfile.local -t "$SERVER_TARGET_IMAGE"

cd "$CLIENT1_DIR" || exit
docker build . -t "$CLIENT1_TARGET_IMAGE"

cd "$CLIENT2_DIR" || exit
docker build . -t "$CLIENT2_TARGET_IMAGE"

cd $GCS_DIR/src || exit
cat <<EOF > _temp_clients_file.json
[
  {
    "id": "client1",
    "name": "Client One!",
    "image": "$CLIENT1_TARGET_IMAGE"
  },
  {
    "id": "client2",
    "name": "Client Two!",
    "image": "$CLIENT2_TARGET_IMAGE"
  }
]
EOF

python3 controller.py "$SERVER_TARGET_IMAGE" _temp_clients_file.json
rm _temp_clients_file.json
