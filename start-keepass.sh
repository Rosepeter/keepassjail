#!/usr/bin/env bash
set -euo pipefail

. ${SUDO_HOME}/.keepassjail
KEEPASSRPC_PORT_INTERNAL=$((KEEPASSRPC_PORT + 1))

IMAGE="keepassjail:latest"
CNI_NETWORK_NAME="podman"

XSOCK="/tmp/.X11-unix"

podman run --rm -it \
    --privileged \
    --name keepassjail \
    --network "$CNI_NETWORK_NAME" \
    -e KP_UID="${SUDO_UID}" \
    -e KP_GID="${SUDO_GID}" \
    -e KP_USER="${SUDO_USER}" \
    -e KP_HOME="${SUDO_HOME}" \
    -e DISPLAY="$DISPLAY" \
    -e XAUTHORITY="/tmp/.container.xauth" \
    -e CONT_KEEPASSRPC_PORT="$KEEPASSRPC_PORT" \
    -e CONT_KEEPASSRPC_PORT_INTNERNAL="$KEEPASSRPC_PORT_INTERNAL" \
    -v "$XSOCK:$XSOCK:rw" \
    -v "$XAUTH:/tmp/.container.xauth:ro" \
    -p $KEEPASSRPC_PORT:$KEEPASSRPC_PORT_INTERNAL/tcp \
    -v "$KEEPASS_DIR:/opt/keepass:rw" \
    -v "$SUDO_HOME:/home/$SUDO_USER:rw" \
    --security-opt=no-new-privileges \
    --cap-drop=ALL \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    "$IMAGE"
