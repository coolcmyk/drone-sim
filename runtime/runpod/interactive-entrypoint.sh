#!/usr/bin/env bash
set -euo pipefail

# A Runpod Pod has one workload container. Keep it alive as an interactive GPU
# machine; the user starts the simulator with sim_up_local.sh from the Pod terminal.
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

mkdir -p /var/log/drone-sim /run/drone-sim /workspace
if [ "${QGC_VNC_ENABLED:-0}" = "1" ]; then
  export QGC_USE_EXISTING_DISPLAY=1
  /usr/local/bin/drone-sim-vnc-desktop &
  desktop_pid=$!
  sleep 2
  if ! kill -0 "$desktop_pid" 2>/dev/null; then
    echo "runner: noVNC desktop failed to start" >&2
    exit 1
  fi
fi
echo "runner: interactive Drone Sim Pod ready"
echo "runner: start the simulator with /opt/drone-sim/runtime/runpod/sim_up_local.sh --detach"
exec sleep infinity
