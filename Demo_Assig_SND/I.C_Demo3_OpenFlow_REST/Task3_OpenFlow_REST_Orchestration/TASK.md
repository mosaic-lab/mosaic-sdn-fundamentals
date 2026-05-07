# Task 3 — Using ONOS RESTful API to Filter, Mirror, and Forward Networking Traffic Based on OpenFlow Capabilities

## Objective
Use the ONOS RESTful API to automate OpenFlow rule creation, listing, and deletion for practical filtering, mirroring, and forwarding scenarios.

## Introduction

This task helps students master OpenFlow flow rules and their application to practical scenarios through the ONOS RESTful API. In contrast to the demonstration dubbed “OpenFlow flow tables”, this task is part of the application layer because it operates at a higher level while still allowing the manipulation of SDN-enabled switches.

By completing this task, students should be able to automate the creation, deletion, and update of OpenFlow flow rules and understand the advantages and limitations of OpenFlow-based orchestration systems.

## Pre-Task

Reuse the Python ONOS REST client created in the previous REST task to access the ONOS RESTful API and activate the required ONOS applications.

In this reorganized demo, the required files are already provided in this folder:

- Use `application.txt` as the application list for ONOS app activation.
- Use `task.sh` as the topology launcher for this task.

These two files replace the original course-material references to the Moodle application list and `demo2_task1.sh`.

## Task 3.1 — Activate Required Applications

Use Python and the ONOS REST API to activate the required ONOS applications before creating any flow rules.

Use `application.txt` in this folder as the source for the required ONOS applications.

## Task 3.2 — Flow Rule Creation Through ONOS REST API

The original assignment refers to `demo2_task1.sh`. In this reorganized demo, use `task.sh` in this folder instead. This shell script creates the predefined topology for this task.

A host in the ONOS GUI is represented here as a namespace, although LXC or LXD containers could also be used in other variants.

Using the topology created by `task.sh`, create flow rules to:

1. mirror traffic from Red to Blue so that the same traffic is also sent to Green
2. block ICMP traffic from Blue to Red
3. block all traffic to Red
4. allow total access to Red from Green and Blue
5. explain whether previously created blocking rules must be deleted before the allowing rule can take effect
6. allow only HTTP and HTTPS traffic to Red

Use only the ONOS RESTful API to create these flow rules.

For each rule, provide the entered-rule details and a short explanation.

## Task 3.3 — Generic Flow Query and Deletion

Using the same predefined topology created by `task.sh`, create Python programs to:

1. list all flow rules per device ID in a generic way suitable for any compatible topology
2. list flow rules by application ID
3. delete a flow rule using the device ID and flow ID

Use only the ONOS RESTful API for this part.

## Student Work

For this task, students must:

- create or complete the required Python file or files inside this task folder
- reuse or extend the ONOS REST client logic from the previous REST task
- use ONOS REST API only for application activation, flow-rule creation, flow listing, and flow deletion
- provide script output or API evidence for each completed subtask
- explain the observed rule-priority behavior where required

## Validation

Validate your work with evidence such as:

```bash
sudo bash task.sh
python3 <your_pretask_or_activation_file>.py
python3 <your_task3_rule_file>.py
python3 <your_task3_query_file>.py
curl -u onos:rocks http://localhost:8181/onos/v1/flows
curl -u onos:rocks http://localhost:8181/onos/v1/applications
```

## Submission

- The Python code used for application activation and ONOS RESTful API flow management
- Output evidence for created flow rules, queried flow rules, and deleted flow rules
- A short explanation of whether rule deletion was required before the allowing rule took effect
- Short troubleshooting notes



