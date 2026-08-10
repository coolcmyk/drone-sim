# `config/` — repository-owned configuration

Configuration is grouped by the thing it controls:

| What | Where | Read by |
|---|---|---|
| the vehicle, sensors, and their tuning | [`../simulator/unreal/settings.json`](../simulator/unreal/settings.json) | the simulator, via `runtime/local/sim_up.sh --settings` |
| DDS transport for a remote peer | [`dds/udp-only.xml`](dds/udp-only.xml) | the remote ROS 2 client |
| mission, tolerances, and recorded topics | [`scenarios/*.yaml`](scenarios/) | `runtime/local/run_scenario.py`, `runtime/local/run_gate.py` |
| the ROS 2 graph | [`../ros2/src/bringup/launch/`](../ros2/src/bringup/launch/) | `ros2 launch` |

Secrets never live here—pass tokens, Wi-Fi credentials, and setup keys by environment or a
local secret file, never by a committed configuration file. See `AGENTS.md`.
includes the GitHub PAT the Unreal engine base image needs.
