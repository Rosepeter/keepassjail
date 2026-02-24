# Hostname allowed for SSH (SftpSync). Resolve inside container.
TARGET_HOST="${TARGET_HOST:-faui48e.informatik.uni-erlangen.de}"
KEEPASSRPC_PORT=${KEEPASSRPC_PORT:-12547}
RETRIES=${RETRIES:-5}

echo "[restrict-nft] resolving ${TARGET_HOST} inside container..."
# small retry loop for DNS readiness
IPS=""
for i in $(seq 1 $RETRIES); do
  IPS=$(getent ahostsv4 "$TARGET_HOST" 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ' ')
  if [ -n "$IPS" ]; then break; fi
  echo "[restrict-nft] DNS not ready, retrying ($i/$RETRIES)..."
  sleep 1
done

echo "[restrict-nft] loading nft-configuration"

nft -f /usr/local/bin/nftables.conf

echo "[restrict-nft] adding ssh target ips to nft"
for ip in $IPS; do
    nft add element inet filter ssh_hosts { $ip }
done

echo "[restrict-nft] adding KeepassRPC-ports to nft"

nft add element inet filter keepassrpc_ports { $KEEPASSRPC_PORT }
