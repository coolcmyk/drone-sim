#!/usr/bin/env bash
set -euo pipefail

readonly script=/opt/drone-sim/scripts/airsim_rpc_client.py
readonly timeout_s="${SETTLE_TIMEOUT:-300}"
readonly samples="${SETTLE_SAMPLES:-5}"
readonly epsilon="${SETTLE_EPS:-0.05}"

test -f "$script"
python3 - "$script" "$timeout_s" "$samples" "$epsilon" <<'PY'
import sys
import time

script, timeout_s, samples, epsilon = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), float(sys.argv[4])
sys.path.insert(0, script.rsplit('/', 1)[0])
from airsim_rpc_client import Rpc

rpc = None
deadline = time.time() + timeout_s
while time.time() < deadline:
    try:
        rpc = Rpc()
        rpc.call("getServerVersion")
        break
    except Exception:
        time.sleep(2)
if rpc is None:
    raise SystemExit("runner: AirSim RPC did not become ready")

stable = 0
previous = None
while time.time() < deadline:
    position = rpc.call("simGetGroundTruthKinematics", "PX4")["position"]
    z = position["z_val"]
    if previous is not None and abs(z - previous) <= epsilon:
        stable += 1
        if stable >= samples:
            print(f"runner: vehicle settled at z={z:+.3f} m")
            raise SystemExit(0)
    else:
        stable = 0
    previous = z
    time.sleep(1)
raise SystemExit("runner: vehicle did not settle before timeout")
PY
