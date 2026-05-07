# Demo2 — Virtualized Topologies (Containers & Linux Namespaces)

## Learning Goal
The main objective of this demonstration is to get some intuition behind the basic infrastructure-layer operations by creating topologies using Linux namespaces and container-based virtualization. By doing this assignment, students will understand low-level infrastructure components, their advantages and limitations, and how they are used in well-known open-source systems such as Kubernetes and OpenStack.

## Setting Up

In this course, we will be using ONOS as an SDN controller along with some dependencies: Docker, OVS, and a Linux machine. It is noted that networking knowledge, familiarity with Linux shell bash, and Python are considered prerequisites.

ONOS is officially supported by the Open Networking Foundation (ONF) and runs on Linux machines and containers such as LXC, LXD, and Docker. If you do not have a suitable Linux environment on your machine, you can use a virtual machine.

For this reorganized demo set, the environment has been tested on Ubuntu 20.04.6 LTS with Python 3.8.10.

Before starting Demo2, make sure the base environment from Demo1 Task 0 is already prepared, especially ONOS, Docker, OVS, and the shared cleanup workflow. See `../Demo1_Mininet_Fundamentals/Task0_Env_setup/01 Install_guide.md`.

## Prerequisites
- Demo1 completed
- Docker, OVS, and ONOS already set up
- Container tooling available as required by the chosen task, such as namespaces, LXC/LXD, or Docker
- Basic Linux networking and Python scripting knowledge

## Files
- `check.sh` — verifies the environment and required container tooling
- `lxc_driver.py` — LXC container helper (reference). This file provides helper functions to create, start, inspect, attach, clone, and delete LXC containers, and to connect them to Linux bridges and OVS ports.
- `README.md` — this file

> [!NOTE]
> In the reference `lxc_driver.py`, the LXC image release is currently pinned to `jammy`.
> This value refers to the Ubuntu release used for the LXC container image, not necessarily the host OS version.
> If your local LXC image list or teaching environment uses a different release, verify and adjust that value before running the container-based tasks.

## Tasks

### Task 1: Namespace Topologies
- Create namespace-based topologies using shell or Python
- Build both linear and tree topologies
- Automate topology generation from input parameters

Task description:
- Create a linear topology with 5 switches and 5 hosts.
- Create a tree topology with depth 3 and fanout 2.
- Automate the previous tasks so that topology type and specifications can be provided as input.

Expected result:
- Namespace-based topologies are created successfully.
- Connectivity works as expected.
- The topology can be regenerated after cleanup without conflicts.

### Task 2: ONOS and Linux Containers
- Build a container-based leaf-spine topology using LXC and LXD
- Automate topology generation from the number of leaves, spines, and hosts
- Reflect briefly on the complexity compared to namespaces

Task description:
- Create a leaf-spine topology with 8 leaf switches and 3 spine switches.
- Attach 2 Linux containers to each leaf switch.
- Use LXC when a leaf number is odd and LXD when a leaf number is even.
- Automate the topology creation process from input parameters.
- Answer the discussion question comparing containers with namespaces.

Expected result:
- The leaf-spine topology is created successfully.
- Containers are attached according to the LXC/LXD rule.
- Automation works and the topology can be recreated after cleanup.

### Task 2.4 (Optional): Docker Variant
- Repeat Task 2.1 and Task 2.2 using Docker containers
- Validate topology creation and automation
- Provide a short comparison with the previous container approach

Task description:
- Recreate the fixed leaf-spine topology using Docker containers.
- Recreate the automation task using Docker containers.
- Keep the resulting topology behavior comparable with the previous container implementation.

Expected result:
- Docker-based topology and automation function correctly.
- A short comparison is provided against the earlier container approach.

## Evidence Required
- Container or namespace creation output
- Topology summary and connectivity evidence
- Cleanup and rerun evidence
- Explanation of implementation choices and comparison notes
- Short troubleshooting notes for any failed runs and fixes applied

## How to Run
```bash
# Step 1: verify the environment and container tooling
bash check.sh

# Step 2: complete the required task in its folder
# Task1_Namespace_Topologies/
# Task2_ONOS_and_Linux_Containers/
# Task3_Docker_Variant/   # optional

# Step 3: clean up before reruns
bash cleanup_all.sh
```

## Grading Checklist
- [ ] Task 1 namespace topologies work correctly
- [ ] Task 2 leaf-spine container topology works correctly
- [ ] Task 2 automation works from input parameters
- [ ] Validation evidence is included for each required task
- [ ] Cleanup works before reruns
- [ ] Discussion and explanations are provided

## Task Folders
- `Task1_Namespace_Topologies/` → `TASK.md`, `ANSWER_TEMPLATE.md`
- `Task2_ONOS_and_Linux_Containers/` → `TASK.md`, `ANSWER_TEMPLATE.md`
- `Task3_Docker_Variant/` → `TASK.md`, `ANSWER_TEMPLATE.md` (optional)
