#!/usr/bin/env bash
set -euo pipefail

DISPLAY_NUM="${DISPLAY_NUM:-:99}"
RES="${RES:-1920x1080}"

if [ "${QGC_VNC_ENABLED:-0}" != "1" ] || [ -z "${QGC_VNC_PASSWORD:-}" ]; then
  echo "runner: QGC_VNC_ENABLED=1 and a non-empty QGC_VNC_PASSWORD are required" >&2
  exit 2
fi

rm -f "/tmp/.X${DISPLAY_NUM#:}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM#:}" 2>/dev/null || true
Xvfb "$DISPLAY_NUM" -screen 0 "${RES}x24" -ac +extension GLX +extension RANDR +render -noreset -nolisten tcp \
  >/tmp/xvfb.log 2>&1 &
sleep 2
if ! xdpyinfo -display "$DISPLAY_NUM" >/dev/null 2>&1; then
  echo "runner: Xvfb failed to start" >&2
  cat /tmp/xvfb.log >&2
  exit 1
fi

openbox >/tmp/openbox.log 2>&1 &
umask 077
password_file="$(mktemp /tmp/qgc-vnc-password.XXXXXX)"
x11vnc -storepasswd "$QGC_VNC_PASSWORD" "$password_file" >/dev/null
x11vnc -display "$DISPLAY_NUM" -rfbauth "$password_file" -localhost -rfbport 5900 -forever -shared \
  >/tmp/x11vnc.log 2>&1 &
websockify --web /usr/share/novnc 6080 localhost:5900 >/tmp/novnc.log 2>&1 &

# The terminal is the deliberate hand-off: users can run sim_up_local.sh without
# needing Docker, SSH, or a second container.
xterm -display "$DISPLAY_NUM" -geometry 130x38+30+30 -title "Drone Sim Pod" \
  -e /bin/bash -lc 'echo "Run: /opt/drone-sim/runtime/runpod/sim_up_local.sh --detach"; exec /bin/bash' &

wait -n
