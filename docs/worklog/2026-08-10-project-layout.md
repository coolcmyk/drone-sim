# 2026-08-10 — Project Layout Refactor

**Scope:** repository paths and documentation only; no real-aircraft, HITL, or simulator command.

## Decision

The repository now separates simulator assets (`simulator/unreal`), ROS code (`ros2`), local and Runpod lifecycle code (`runtime/local`, `runtime/runpod`), the supported stack image (`containers/stack`), retained local multi-image Dockerfiles (`containers/legacy`), configuration (`config`), and pinned upstream metadata (`third_party`).

The old supervisor entrypoint, supervisor configuration, and settle helper were unreachable after the interactive Pod launcher became the image entrypoint, so they were removed. The project-level `AGENTS.md` remains; duplicate nested tool-specific instruction Markdown was removed.

## Verification

Shell and Python parsing succeeded. The off-target test suite is run with third-party pytest plugin autoload disabled because the globally installed `launch_testing` plugin is incompatible with the installed pytest version. No GPU or SITL run is needed for a path-only change.
