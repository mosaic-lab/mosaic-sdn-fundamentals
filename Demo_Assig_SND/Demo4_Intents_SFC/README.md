# Demo4 — Intents and Service Function Chaining (SFC)

## Learning Goal
Use ONOS intents and intent-based orchestration to study high-level connectivity policies and static service function chaining behavior.

## Prerequisites
- Demo3 complete
- ONOS REST API reachable
- Host discovery and `tcpdump` available
- Basic understanding of P2P, H2H, and S2MP intents

## Current Structure
- `check.sh` — basic environment check for this demo
- `Task1_Intent_Basics/` — intent basics task files, local application list, and topology launcher
- `Task2_SFC_Steering/` — SFC task files and local topology launchers
- `README.md` — this file

## Demo Overview
This demo covers two related application-layer topics:

1. Intent basics through ONOS RESTful API: point-to-point, host-to-host, and single-to-multipoint intents.
2. Service Function Chaining (SFC): using intent-based orchestration to steer traffic through an intermediate service function.

The reorganized demo intentionally keeps the student-facing task material inside the task folders, so the authoritative instructions for each task are the `TASK.md` files in those folders.

## Task 1
Title: `Using ONOS RESTful API to Filter, Mirror, and Forward Networking Traffic Based on ONOS's Intents Framework`

What students do:
- activate the required ONOS applications
- launch the Task 1 topology from `Task1_Intent_Basics/task.sh`
- create and delete P2P, H2H, and S2MP intents
- explain host-to-host abstraction and path selection
- compare intent-based networking with OpenFlow-rule programming

Key local files:
- `Task1_Intent_Basics/TASK.md`
- `Task1_Intent_Basics/ANSWER_TEMPLATE.md`
- `Task1_Intent_Basics/application_list.txt`
- `Task1_Intent_Basics/task.sh`

Important note:
- `org.onosproject.fwd` should be inactive during intent validation, otherwise reactive forwarding may mask the behavior of intent-compiled flows.

## Task 2
Title: `Using ONOS RESTful API, Linux Containers, and Intent-Based Networking to Orchestrate SFC`

What students do:
- start from a baseline H2H intent between RED and GREEN
- observe the baseline path with `tcpdump`
- explain why baseline H2H behavior may be insufficient for SFC
- delete the baseline intent
- choose an SFC-capable intent design and steer traffic through BLUE
- explain the end-to-end path construction method

Key local files:
- `Task2_SFC_Steering/TASK.md`
- `Task2_SFC_Steering/ANSWER_TEMPLATE.md`
- `Task2_SFC_Steering/sfc.py` — primary launcher matching the original container-based assignment style most closely
- `Task2_SFC_Steering/task.sh` — namespace-based local equivalent for lighter environments

Important notes:
- Use only one Task 2 launcher per run: `sfc.py` or `task.sh`.
- Students do not need to create a separate intent between BLUE interfaces `10.0.0.111` and `10.0.0.112`; BLUE itself provides that forwarding behavior as the service function.
- Baseline H2H traffic may follow the shortest path without traversing BLUE. That observation is valid and should be discussed.

## How to Use This Demo
1. Run `bash check.sh` to confirm the base environment.
2. Open the relevant task folder and follow its `TASK.md`.
3. Use the matching `ANSWER_TEMPLATE.md` for student submissions.
4. Keep task-specific launchers and local helper files inside their task folders.

## Task Folders
- `Task1_Intent_Basics/` → `TASK.md`, `ANSWER_TEMPLATE.md`, `application_list.txt`, `task.sh`
- `Task2_SFC_Steering/` → `TASK.md`, `ANSWER_TEMPLATE.md`, `sfc.py`, `task.sh`
