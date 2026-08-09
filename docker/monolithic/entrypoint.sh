#!/usr/bin/env bash
set -euo pipefail

# A standard Runpod Pod runs this one container. All simulator services are subprocesses
# in its one network namespace, so 127.0.0.1 remains private to the image.
# Fern forces Fast-DDS onto loopback UDP because the Runpod Pod API does not expose a
# shared-memory-size setting. A non-UDP deployment must provide the native stack's 2 GiB shm.
if [ "${FASTDDS_BUILTIN_TRANSPORTS:-UDPv4}" != "UDPv4" ]; then
  if [ ! -d /dev/shm ]; then
    echo "runner: /dev/shm is unavailable; refusing non-UDP Fast-DDS" >&2
    exit 1
  fi
  shm_bytes="$(df -B1 /dev/shm | awk 'NR == 2 {print $2}')"
  if [ "${shm_bytes:-0}" -lt 2147483648 ]; then
    echo "runner: /dev/shm is ${shm_bytes:-0} bytes; non-UDP Fast-DDS requires 2 GiB" >&2
    exit 1
  fi
fi

mkdir -p /var/log/drone-sim /run/drone-sim
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
