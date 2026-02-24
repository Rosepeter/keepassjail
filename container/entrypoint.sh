#!/usr/bin/env bash
set -euo pipefail

echo "[entrypoint] Applying network restrictions..."
/usr/local/bin/restrict-nft.sh

# Create user inside container matching host uid/gid later
userdel ubuntu
useradd -M -d "/home/$KP_USER" -s /bin/bash -u "$KP_UID" -g "$KP_GID" "$KP_USER"
export HOME=/home/$KP_USER

chown "${KP_UID}:${KP_GID}" /opt/keepass || true
chmod 700 /opt/keepass || true

echo "[entrypoint] Dropping privileges..."
# UID and GID are injected by wrapper:
gosu "$KP_UID:$KP_GID" /usr/local/bin/run_keepass.sh &
KEEPASS_PID=$!

sleep 5

# 2. Wait until KeePassRPC port 22546 is open
#while ! nc -z 127.0.0.1 22546; do
#    sleep 0.5
#done

echo "[entrypoint] Starting socat..."
# Forward all interfaces -> localhost
socat TCP-LISTEN:$CONT_KEEPASSRPC_PORT_INTNERNAL,bind=0.0.0.0,reuseaddr,fork TCP:127.0.0.1:$CONT_KEEPASSRPC_PORT &
SOCAT_PID=$!

wait $KEEPASS_PID

echo "[entrypoint] Stopping socat..."
kill $SOCAT_PID
