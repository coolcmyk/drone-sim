# Agent guide

## Purpose

Drone Sim is a pure PX4 SITL simulator: Unreal Engine 5.8 + Cosys-AirSim, PX4 v1.16, ROS 2 Jazzy, and QGroundControl. The simulator—not an application built on top of it—is the product.

Use ROS 2 (`px4_msgs` over Micro XRCE-DDS) for vehicle control. Use AirSim RPC only for simulator and world operations; MAVLink is an internal simulator transport.

## Safety

- Treat all launch and control work as SITL unless the operator explicitly says otherwise.
- Never arm, send setpoints to, or run HITL/real hardware without explicit approval immediately before that specific run.
- Never expose unauthenticated MAVLink ports outside a trusted network by default.
- Keep tokens, credentials, and secret files out of the repository and Git history.
- Ask before executing on a host outside the current development container or environment.

## Start here

Read only the documentation relevant to the change:

- `docs/quickstart.md` — build, launch, and runtime prerequisites
- `docs/conventions.md` — ROS 2 graph and frame conventions
- `third_party/versions.lock` — source, image, and toolchain pins
- `docs/todo.md` and `docs/docker/todo.md` — active work and acceptance criteria
- `docs/architecture.html`, `docs/worlds.md`, and `docs/bench.md` — architecture, worlds, and GPU constraints

Repository map:

```text
simulator/       Unreal integration and PX4 configuration
ros2/            ROS 2 interfaces, control, and bring-up
runtime/         Local and Fern/Runpod launch scripts
containers/      Stack and legacy image definitions
config/          DDS and scenario configuration
third_party/     Upstream manifests and version locks
docs/            User and design documentation
tests/           Automated checks
```

## Change rules

- Start non-trivial feature work from a tracked issue or an entry in the active backlog. State the acceptance test before changing code.
- Keep diffs small and focused. Do not combine refactors with behavior changes unless required.
- Preserve upstream code in `vendor/`. Put integration patches under `simulator/unreal/patches/` and record intentional divergence in `docs/vendor/`.
- Pin dependencies to immutable SHAs or image digests in `third_party/versions.lock`; never rely on a moving branch or tag alias.
- Keep the ROS 2 graph stable. Do not rename or wrap PX4 topics; use existing parameters and launch conventions.
- Do not edit existing dated worklogs. Add a new worklog only for a substantive investigation or multi-step implementation, and record concrete evidence rather than a retrospective narrative.
- Do not add agent/tool attribution, co-author trailers, or generated-by notices to code, docs, commits, PRs, or issues.

## Validation

Use the smallest check that proves the change:

```bash
./runtime/local/run_local_ci.sh      # fast off-target checks
make html                            # documentation build
```

For flight, control, perception, launch, container, or pin changes, also run the relevant simulator scenario or gate when a GPU environment is available. Record the command and evidence (MCAP, metrics, or logs). If full validation is unavailable, state the concrete blocker; do not imply that an unrun simulator test passed.

Before the docs build, create a virtual environment and install `docs/requirements.txt` with `docs/constraints.txt` if Sphinx is not already available.

## Git and review

- Do not commit, push, open a PR, or merge unless the user explicitly asks in the current request.
- Use a feature branch and PR for code, runtime, container, or dependency-pin changes. Keep documentation-only changes reviewable and follow the requested branch strategy.
- Run the relevant checks before requesting review. Never auto-merge unless explicitly authorized.
- In GitHub text, use bare `#N` only for an issue or PR in this repository. Use `owner/repo#N` for another repository and avoid bare internal numeric identifiers in commit messages.

## References

Keep detailed rationale, historical investigations, benchmark figures, and host-specific notes in `docs/`, especially `docs/worklog/`, `docs/history/`, `docs/bench.md`, and `docs/docker/todo.md`. Add nested `AGENTS.md` files only when a subtree needs rules that do not apply to the entire repository.
