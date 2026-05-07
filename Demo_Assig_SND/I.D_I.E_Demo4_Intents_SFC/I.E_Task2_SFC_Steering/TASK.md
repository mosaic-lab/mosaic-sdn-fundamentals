# Task 2 — Using ONOS RESTful API, Linux Containers, and Intent-Based Networking to Orchestrate SFC

## Objective
Use the ONOS RESTful API to develop hands-on experience with Service Function Chaining (SFC) and SDN-based system orchestration on a predefined topology.

## Introduction

This task aims to develop hands-on experience with Service Function Chaining (SFC) and SDN-based system orchestration through the use of the ONOS RESTful API. This task is part of the application layer because it introduces students to general orchestration methods and programmability in SDN-based environments.

By completing this task, students will become familiar with the basics and operations of creating static SFC instances and their related network traffic. Students will also develop technical knowledge useful for understanding more complex implementations used in well-known open-source projects such as OpenStack.

## Pre-Task

Use the Python code created in the previous demonstration to access the ONOS RESTful API and activate the required ONOS applications.

In this reorganized demo:

- use the same ONOS REST client and app-activation workflow from Demo4 Task 1
- use `Task1_Intent_Basics/application_list.txt` as the local application list unless your course package provides a dedicated Task 2 list
- keep `org.onosproject.fwd` inactive before validating SFC-related intents

## Student Work

All subtasks are performed on a predefined topology in which students create intents to achieve the required SFC communication.

The original assignment refers to `sfc.py` from the course materials. In this reorganized demo, use `sfc.py` as the primary topology launcher for this task.

If a lighter local setup is preferred, `task.sh` may be used as a namespace-based equivalent of the same scenario.

In this scenario, RED is the source, GREEN is the destination, and BLUE is the simplified service function. BLUE receives traffic on one interface and forwards it out through the other interface.

Students do not need to create a separate intent between BLUE interfaces `10.0.0.111` and `10.0.0.112`; BLUE itself performs that forwarding behavior as the service function.

For this task, students must use Python-based code and the ONOS RESTful API to:

1. create a Host-to-Host intent to allow communication between the RED and GREEN containers
2. use `tcpdump` or a similar tool to identify the path taken by traffic from RED to GREEN
3. report what is observed about the baseline path
4. explain whether Host-to-Host intents are useful for SFC deployments
5. delete all created intents using Python-based code and the ONOS RESTful API
6. identify what kind of intents can be used to activate SFC communication in the current scenario
7. using the appropriate intent type, create Python-based code to steer traffic as required by the SFC scenario
8. explain the method used to create the end-to-end path

For each intent, provide the entered intent details and a short explanation.

Use only the ONOS RESTful API to create and delete the intents and to orchestrate the SFC traffic.

## Practical Notes

- Use only one topology launcher for a given run: `sfc.py` or `task.sh`, not both at the same time.
- In the baseline Host-to-Host step, the selected shortest path may not traverse BLUE. That observation is valid and is part of the reason students must evaluate whether H2H intents are suitable for SFC.
- When validating paths with `tcpdump`, capture on the host-side interfaces created by the topology launcher; you do not need to install `tcpdump` inside the containers or namespaces.
- Delete the baseline Host-to-Host intent before testing the final SFC steering logic, otherwise earlier intents may interfere with the observed behavior.
- No separate intent is required between BLUE interfaces `10.0.0.111` and `10.0.0.112`; BLUE itself provides that forwarding behavior as the service function.

## Validation

Validate your work with evidence such as:

```bash
python3 pretask.py
python3 Task2_SFC_Steering/sfc.py
# optional local alternative: sudo bash Task2_SFC_Steering/task.sh
python3 task_sfc.py
curl -u onos:rocks http://localhost:8181/onos/v1/intents
tcpdump
ping
```

## Submission

- The Python code used for baseline intent creation, deletion, and SFC steering
- Baseline path evidence and steered SFC path evidence
- A short explanation of why the baseline Host-to-Host intent is or is not suitable for SFC
- The explanation of the end-to-end steering method and chosen intent type



