#!/usr/bin/env bash
set -euo pipefail

# Run the full local service graph inside the image. This intentionally does not
# call Docker: a standard Runpod Pod already is the container boundary.
LOG_DIR="${DRONE_SIM_LOG_DIR:-/var/log/drone-sim}"
RUN_DIR="${DRONE_SIM_RUN_DIR:-/run/drone-sim}"
PIDFILE="$RUN_DIR/sim_up_local.pids"
DETACH=0
STOP=0

usage() {
  cat <<'USAGE'
Usage: sim_up_local.sh [--detach | --foreground | --stop]

Starts Unreal/Cosys-AirSim, Micro-XRCE-DDS Agent, QGroundControl (and noVNC
when QGC_VNC_ENABLED=1), then PX4 SITL in this Pod's network namespace.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --detach) DETACH=1 ;;
    --foreground) DETACH=0 ;;
    --stop) STOP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "runner: unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

mkdir -p "$LOG_DIR" "$RUN_DIR"

if [ "$STOP" -eq 1 ]; then
  if [ -f "$PIDFILE" ]; then
    while IFS= read -r pid; do
      kill -TERM "$pid" 2>/dev/null || true
    done < "$PIDFILE"
    rm -f "$PIDFILE"
    echo "runner: stop requested"
  else
    echo "runner: no local simulator process list found"
  fi
  exit 0
fi

if [ "$DETACH" -eq 1 ] && [ "${SIM_UP_LOCAL_DETACHED:-0}" != "1" ]; then
  export SIM_UP_LOCAL_DETACHED=1
  setsid "$0" --foreground >"$LOG_DIR/sim_up_local.log" 2>&1 < /dev/null &
  echo "runner: simulator launcher started (pid $!); logs: $LOG_DIR"
  exit 0
fi

if [ -f "$PIDFILE" ]; then
  echo "runner: simulator already started; use --stop before starting again" >&2
  exit 1
fi

declare -a PIDS=()
cleanup() {
  local status=$?
  trap - EXIT INT TERM
  for pid in "${PIDS[@]:-}"; do
    kill -TERM "$pid" 2>/dev/null || true
  done
  wait "${PIDS[@]:-}" 2>/dev/null || true
  rm -f "$PIDFILE"
  exit "$status"
}
trap cleanup EXIT INT TERM

start() {
  local name=$1
  shift
  "$@" >"$LOG_DIR/$name.log" 2>&1 &
  local pid=$!
  PIDS+=("$pid")
  printf '%s\n' "$pid" >> "$PIDFILE"
  echo "runner: started $name (pid $pid)"
}

start unreal /usr/sbin/runuser -u ue4 -- /bin/bash -lc \
  'exec /home/ue4/UnrealEngine/Engine/Binaries/Linux/UnrealEditor /opt/Cosys-AirSim/Unreal/Environments/Blocks/Blocks.uproject -game -RenderOffScreen -nosound -unattended -stdout -settings=/opt/drone-sim/settings.json'
start xrce /bin/bash -lc \
  'source /opt/ros/jazzy/setup.bash; while true; do /usr/local/bin/MicroXRCEAgent udp4 -p 8888; sleep 2; done'
start qgc /usr/local/bin/qgc-entrypoint.sh

start px4 /usr/local/bin/drone-sim-start-px4
/usr/local/bin/drone-sim-readiness >"$LOG_DIR/readiness.log" 2>&1
echo "runner: Drone Sim stack is ready"

wait -n "${PIDS[@]}"
echo "runner: a simulator service exited; stopping the stack" >&2
exit 1
