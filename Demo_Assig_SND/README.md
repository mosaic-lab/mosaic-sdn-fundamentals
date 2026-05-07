# Demo_SND — Progressive SDN Teaching Structure

This folder organizes the SDN teaching material into four progressive demos, moving from basic emulation to container-based virtualization, OpenFlow control, and finally intent-based orchestration and service function chaining.

## Demo Progression

1. **Demo1_Mininet_Fundamentals** — Mininet CLI and Python API topologies, local and remote controllers, and topology automation
2. **Demo2_Virtualized_Topologies** — Linux namespaces, LXC/LXD containers, and optional Docker-based topology automation
3. **Demo3_OpenFlow_REST** — manual OpenFlow rule behavior, controller-resource management through ONOS REST API, and REST-based flow orchestration
4. **Demo4_Intents_SFC** — ONOS intents, intent abstraction, and service function chaining through intent-based orchestration

## How This Repository Is Organized

Each demo has its own `README.md` describing the learning goal, prerequisites, tasks, and expected outcomes.

Each task is kept in its own task folder, typically containing:
- `TASK.md` — the student-facing task description
- `ANSWER_TEMPLATE.md` — the suggested answer/submission structure
- local helper files such as `task.sh`, `sfc.py`, or `application_list.txt` when needed by that task

This reorganized structure keeps task-specific files close to the task itself instead of assuming a large shared root-level runtime package.

## Shared Utilities

The `common/` folder contains reusable cleanup utilities shared across the demos:
- `common/topology_cleanup.sh` — removes lab-created topology state on the host, including namespaces, OVS bridges, and veth interfaces
- `common/onos_cleanup.sh` — removes stale ONOS-side state through the REST API when devices or topology elements remain visible after teardown
- `common/clean_all.sh` — performs a broader reset of topology state and ONOS runtime state; use this before reruns when stale flows, intents, hosts, or devices may affect results

## Demo Notes

### Demo 1 — Mininet Fundamentals
- Focuses on CLI topologies, Python API topologies, and automation of Mininet-based labs
- Starts from the environment setup guide in `Task0_Env_setup/01 Install_guide.md`

### Demo 2 — Virtualized Topologies
- Moves from Mininet to namespaces and container-based infrastructure
- Covers namespace topologies, ONOS with Linux containers, and an optional Docker variant

### Demo 3 — OpenFlow and ONOS REST API
- Combines low-level OpenFlow rule behavior with higher-level ONOS REST API management
- Includes manual flow-rule experiments, controller-resource queries, and REST-driven flow orchestration

### Demo 4 — Intents and SFC
- Focuses on ONOS intent abstractions and service function chaining
- Keeps student-facing task instructions inside the task folders, where each task also carries its local launcher files and helper assets

## Recommended Workflow

1. Read the `README.md` inside the target demo folder.
2. Open the relevant task folder and follow its `TASK.md`.
3. Use the matching `ANSWER_TEMPLATE.md` for student submissions.
4. Run the demo-specific `check.sh` when available.
5. Use the shared cleanup scripts in `common/` before reruns if stale topology or controller state may interfere.
