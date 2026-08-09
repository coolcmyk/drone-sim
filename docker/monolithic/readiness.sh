#!/usr/bin/env bash
set -euo pipefail

source /opt/ros/jazzy/setup.bash
source /opt/drone-sim/ros2_ws/install/setup.bash

for _ in $(seq 1 "${READINESS_RETRIES:-120}"); do
  value="$(timeout 8 ros2 topic echo --qos-reliability best_effort --qos-durability volatile \
    --once --field ref_alt /fmu/out/vehicle_local_position 2>/dev/null | grep -vE '^-{3}$' | head -1 || true)"
  if [ -n "$value" ] && python3 -c 'import math,sys; sys.exit(0 if math.isfinite(float(sys.argv[1])) else 1)' "$value"; then
    touch /run/drone-sim/ready
    echo "runner: Drone Sim is ready (finite PX4 EKF origin)"
    exit 0
  fi
  sleep 2
done

echo "runner: readiness failed; finite PX4 EKF origin did not appear" >&2
exit 1
