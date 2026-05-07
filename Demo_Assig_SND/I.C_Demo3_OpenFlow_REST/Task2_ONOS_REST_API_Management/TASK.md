# Task 2 — Using ONOS RESTful API Interface to Manage Hosts, Devices, Applications and Settings

## Objective
Use the ONOS RESTful API to understand and manage the basic ONOS controller resources, including applications, devices, hosts, links, flows, intents, and related controller information.

## Introduction

This task aims to help students experience and understand the basic functionalities of the SDN controller ONOS through its RESTful API. This task is part of the application layer because it introduces general orchestration methods and programmability in SDN-based environments.

By doing this task, students will become familiar with the building blocks required to create more complex ONOS REST-based applications and extract information related to devices, hosts, networking, topologies, settings, and applications.

## Pre-Task Setup

Create a Python-based client or use an existing Python client to interact with the ONOS RESTful API. Your code should be reusable and able to handle changes in usernames and passwords.

Use `application_list.txt` in this folder as the source for the required ONOS applications. This application-activation work is part of Task 2 and is not a separate pre-task.

## Task 2.1 — Activate Required Applications

Unlike the previous demonstrations, the required ONOS applications are not assumed to be active. Students must activate the required applications using a Python-based approach through the ONOS REST API.

Default ONOS credentials may be used unless your environment differs.

## Task 2.2 — Devices

Use `task.sh` in this folder as the predefined topology for this task, then create Python programs to:

1. list all available devices by their IDs
2. get the IP management address and the OpenFlow version used by a given device
3. using the same device ID, get the currently active MAC addresses and port names

## Task 2.3 — Hosts

Using the topology started by `task.sh`, create Python programs to:

1. list all available hosts by their ID, MAC address, and IP address
2. get the device ID and the port used by the host having `10.0.0.130` as its IP address
3. using the same host ID, remove the host from the topology
4. ping the removed host and describe what you observe

## Task 2.4 — Links, Flows, and Intents

Using the same `task.sh` topology, create Python programs to:

1. list all ACTIVE links in the topology, showing source device ID, source port, destination device ID, and destination port
2. list all flows applied to a device of your choice, including flow ID, application ID, device ID, and instructions
3. list all intents

## Student Work

For this task, students must:

- create or complete the required Python file inside this task folder
- use the ONOS RESTful API for all queries and management operations
- provide command output or script output as evidence
- explain the observed behavior where required

## Validation

Validate your work with evidence such as:

```bash
sudo bash task.sh
python3 <your_task2_file>.py
curl -u onos:rocks http://localhost:8181/onos/v1/devices
curl -u onos:rocks http://localhost:8181/onos/v1/hosts
curl -u onos:rocks http://localhost:8181/onos/v1/links
curl -u onos:rocks http://localhost:8181/onos/v1/intents
```

## Submission

- The Python code used for the ONOS RESTful API tasks
- Output evidence for application activation, devices, hosts, links, flows, and intents
- A short explanation of what was observed after removing the selected host
- Short troubleshooting notes

