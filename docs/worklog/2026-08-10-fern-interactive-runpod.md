# 2026-08-10 — Interactive Drone Sim Pod for Fern

**Scope:** pure SITL only. No real aircraft, HITL transport, hardware command, or external
MAVLink/DDS port is involved.

## Decision

A standard Runpod Pod is already the container boundary and cannot launch the repository's
Docker-based `scripts/sim_up.sh`. The Fern runtime therefore remains one image, but it now
boots as an interactive GPU machine. Fern's existing `--vnc-viewer` profile publishes only
password-protected noVNC on port 6080; the image starts Xvfb, openbox and an xterm immediately
so that URL is useful before the simulator is launched.

The operator starts the local service graph from the Pod:

```bash
/opt/drone-sim/scripts/sim_up_local.sh --detach
```

The launcher starts Unreal/Cosys-AirSim, Micro-XRCE-DDS Agent, QGroundControl and PX4 SITL in
one Pod-local network namespace. QGroundControl reuses the pre-existing display and does not
try to create another noVNC server. MAVLink, DDS, AirSim RPC and raw VNC stay local.

## Build constraint

The Epic UE base is Jammy. Jazzy is built from the pinned source revision in that compatible
base rather than copied from a Noble image. The GitHub-hosted build previously reached the ROS
source build and then failed with `No space left on device`; the build is now limited to the
runtime dependency closure (CLI, launch, Fast-DDS, MCAP, rclcpp/rclpy, TF and image transport).
Fern's publisher also deletes known unused SDKs from its ephemeral GitHub runner before Buildx.

## Verification recorded here

- `bash -n` passed for the new interactive entrypoint, desktop/noVNC launcher, QGC entrypoint
  and local service launcher.
- `sim_up_local.sh --help` passed and documents the operator interface.
- `git diff --check` passed in Drone Sim and Fern worktrees.
- No image build, Runpod Pod, noVNC browser session or SITL readiness gate has run yet. Those
  require the pushed branches to merge and the Fern GitHub Actions image publisher to finish.

The work is deliberately described as unverified end-to-end until the published image has been
started through Fern and the browser desktop plus finite-EKF-origin readiness are observed.
