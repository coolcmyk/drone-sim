# Drone Sim

Drone Sim is a reproducible PX4 SITL environment for flying and testing a drone in Unreal Engine worlds.

It combines Unreal Engine and Cosys-AirSim for simulation, PX4 for the flight controller, ROS 2 Jazzy for robotics integration, and QGroundControl for the ground station. The supported target is simulation only; do not use this repository's launch commands with real aircraft or HITL hardware.

## Features

- Unreal Engine 5.8 with Cosys-AirSim worlds and sensors
- PX4 v1.16 SITL with Micro XRCE-DDS
- ROS 2 Jazzy interfaces, control examples, and bring-up
- QGroundControl, with optional browser-based VNC on a Fern/Runpod machine
- Pinned upstream sources and container builds for repeatable environments

## Quick start

The recommended remote workflow is to use Fern to create a GPU Runpod machine, then start the stack from the checked-out repository. See the [quick start](docs/quickstart.md) for the required image access, setup, launch, readiness checks, and VNC connection.

For a local Docker workflow, fetch the pinned sources and use the local runtime scripts:

```bash
vcs import vendor < third_party/sources.repos
./runtime/local/build_blocks.sh
./runtime/local/sim_up.sh
```

The renderer requires an NVIDIA GPU. Building or running the Unreal image also requires access to Epic Games' GitHub Container Registry package. The full prerequisites and image-build instructions are in the [quick start](docs/quickstart.md).

## Repository layout

```text
simulator/       Unreal integration, patches, and PX4 configuration
ros2/            ROS 2 packages: interfaces, control, and bring-up
runtime/         Local and Runpod/Fern launch and lifecycle scripts
containers/      Supported stack image and legacy local image definitions
config/          DDS profiles and simulation scenarios
third_party/     Pinned upstream source manifests and version locks
docs/            User guides, architecture, and development notes
tests/           Automated checks
```

## Documentation

- [Quick start](docs/quickstart.md) — prerequisites, build, launch, and validation
- [Architecture](docs/architecture.html) — component boundaries and data flow
- [Worlds](docs/worlds.md) — using and configuring Unreal worlds
- [Conventions](docs/conventions.md) — project and contribution conventions
- [Docker backlog](docs/docker/todo.md) — known container work
- [Version lock](third_party/versions.lock) — pinned upstream revisions

Build the documentation site locally with:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r docs/requirements.txt -c docs/constraints.txt
make html
```

Open `build/docs/html/index.html`, or run `make serve` for local live reload.

## Contributing

Keep changes focused, update the relevant documentation and tests, and preserve pinned upstream revisions. Open an issue for each feature or fix before implementing it so work can be reviewed in small, traceable pieces.
