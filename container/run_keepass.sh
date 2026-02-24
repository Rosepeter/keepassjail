#!/usr/bin/env bash
set -euo pipefail

echo "[run_keepass] HOME=$HOME"
/usr/bin/mono /opt/keepass/KeePass.exe
