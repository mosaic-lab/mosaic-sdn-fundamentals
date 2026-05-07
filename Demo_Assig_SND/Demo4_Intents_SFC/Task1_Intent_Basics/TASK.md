# Task 1 — Using ONOS RESTful API to Filter, Mirror, and Forward Networking Traffic Based on ONOS's Intents Framework

## Objective
Use the ONOS RESTful API to examine, test, and understand the ONOS intent framework through practical intent-creation tasks on a predefined topology.

## Introduction

This task aims to examine, test, and understand the ONOS intent framework features through the use of the ONOS RESTful API. This task is part of the application layer because it introduces students to general orchestration methods and programmability in SDN-based environments.

By doing this task, students will be able to differentiate intent-based networking from basic OpenFlow-enabled networks and legacy networking systems. Students will also understand the utility of abstracted networking approaches for fast and efficient network development.

## Pre-Task

Use the Python code created in the previous demonstration to access the ONOS RESTful API and activate the required ONOS applications.

In this reorganized demo, use the local files already provided in this folder:

- Use `application_list.txt` as the application list for ONOS app activation.
- Use `task.sh` as the topology launcher for this task.

> [!IMPORTANT]
> Ensure `org.onosproject.fwd` (reactive forwarding) is inactive before testing intents. Otherwise it may install its own flow rules and interfere with or mask the behavior of intent-compiled flows.
>
> If `fwd` was active earlier, old flow rules may still remain in ONOS or on the switches. In that case, deactivate `fwd` and clean stale flows before validating Task 1 results.

## Student Work

This task is a series of intent-based subtasks performed on the predefined topology created by `task.sh`.

The original assignment refers to `demo3_task.sh`. In this reorganized demo, use `task.sh` in this folder instead.

A host in the ONOS GUI is represented here as a namespace, although LXC or LXD containers can also be used in other variants.

Complete the task by using Python-based code and the ONOS RESTful API to:

1. create a series of point-to-point intents to allow communication between the RED namespace and the BLACK namespace
2. delete all created intents
3. create a host-to-host intent to allow communication between the RED namespace and the BLACK namespace
4. explain whether the host-to-host intent is an abstraction of the point-to-point intents
5. identify the path selected by the host-to-host intent
6. provide a hypothesis on how the host-to-host intent selects paths
7. use host-to-host intents to enable communication between all namespaces in the topology
8. without deleting the current intents, create a single-to-multipoint intent to allow communication between RED and BLACK, BLUE, and GREEN
9. restrict the single-to-multipoint intent to communication on port 4009 and verify it with `nc` or a similar tool
10. explain the benefits of intent-based networking compared with OpenFlow flow rules

For each intent, provide the entered intent details and a short explanation.

Use only the ONOS RESTful API interface to create and delete the intents.

## Validation

Validate your work with evidence such as:

```bash
sudo bash task.sh
python3 <your_pretask_or_activation_file>.py
python3 <your_task1_intent_file>.py
curl -u onos:rocks http://localhost:8181/onos/v1/intents
nc -vz <target_ip> 4009
tcpdump
```

## Submission

- The Python code used for intent creation, deletion, and validation
- Output evidence for P2P, H2H, and S2MP intents
- Path-selection evidence and the corresponding hypothesis
- A short comparison between intent-based networking and OpenFlow flow rules
