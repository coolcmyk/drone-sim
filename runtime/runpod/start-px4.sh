#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/drone-sim-wait-for-settle
stty min 1 time 0 2>/dev/null || true
cd /opt/px4/build/px4_sitl_default
exec env PX4_SYS_AUTOSTART=10016 PX4_SIM_HOSTNAME=127.0.0.1 \
  ./bin/px4 -s etc/init.d-posix/rcS -d
