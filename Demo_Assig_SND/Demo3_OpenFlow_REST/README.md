# Demo3 — OpenFlow Flow Tables and Rule Management

## Learning Goal
Understand OpenFlow flow-table behavior, traffic restriction policies, and rule priority. Students will learn to create and analyze OpenFlow rules on a predefined topology and to build a restricted sliced topology using OVS-based rules.

## Prerequisites
- Demo2 complete
- ONOS controller reachable at `$ONOS_HOST:$ONOS_PORT` (default 127.0.0.1:8181)
- ONOS credentials set (default: onos/rocks)

## Files
- `check.sh` — validates ONOS reachability and basic connectivity
- `Task1_Flow_Rule_Creation/` — Task 1 prompt, answer template, and predefined topology script
- `Task2_ONOS_REST_API_Management/` — Task 2 prompt, answer template, and `application_list.txt`
- `Task3_OpenFlow_REST_Orchestration/` — Task 3 prompt, answer template, `task.sh`, and `application.txt` for REST-based OpenFlow rule orchestration
- `README.md` — this file

## Tasks

### Task 1: OpenFlow Flow Tables
Task 1 is divided into two parts.

Task description:
- Part 1: use `task3.1_topology.sh` to create the predefined **Task 3.1 Topology**, then create OpenFlow rules to enforce the requested traffic behavior.
- Block ICMP from Blue to Red.
- Block all traffic to Red.
- Allow total access to Red from Green and Blue.
- Explain whether a previous blocking rule must be deleted before the new allowing rule takes effect.
- Allow only HTTP and HTTPS traffic to Red.
- Use only the OVS command line to enter the flow rules for this part.
- Part 2: create the **Task 3.2 Scenario**, a pseudo network slice with a linear topology of 5 switches and 10 hosts.
- Build two isolated slices, Red and Blue, with no shared access.
- Redo the isolation using a second approach different from the first one.
- Explore VLAN-based isolation as one possible method.

Expected result:
- Flow rules produce the requested traffic restrictions and allowances.
- Rule priority and interaction behavior are explained correctly.
- The 5-switch 10-host sliced topology is created successfully.
- Two fully isolated slices are demonstrated using two different approaches.

### Task 2: Using ONOS RESTful API Interface to Manage Hosts, Devices, Applications and Settings
- Use Python and ONOS REST API to query applications, devices, hosts, links, flows, and intents
- Build reusable client logic that can handle credential changes
- Inspect and manage controller state from the application layer

Task description:
- First, activate the required ONOS applications through Python and the REST API.
- Query devices and extract management IP addresses, OpenFlow version, MAC addresses, and port names.
- Query hosts, locate a host by IP address, remove it, and observe the result.
- Query ACTIVE links, flows on a chosen device, and all intents.

Expected result:
- Required applications are activated successfully.
- Device, host, link, flow, and intent information is retrieved correctly.
- Host removal works and the resulting behavior is explained clearly.

### Task 3: Using ONOS RESTful API to Filter, Mirror, and Forward Networking Traffic Based on OpenFlow Capabilities
- Reuse the Python ONOS REST client from Task 2 to manage flow rules from the application layer
- Recreate the traffic-control scenarios from Task 1 through ONOS REST API instead of manual `ovs-ofctl` commands
- Generalize flow listing and deletion logic so it can work on any compatible topology

Task description:
- First, use the Python client from the previous REST task to activate the required ONOS applications.
- Then use `Task3_OpenFlow_REST_Orchestration/task.sh` and `Task3_OpenFlow_REST_Orchestration/application.txt` with ONOS REST API to create flow rules for mirroring, blocking, allowing, and HTTP/HTTPS-only forwarding scenarios.
- Finally, implement generic Python utilities to list flow rules by device ID, list flow rules by application ID, and delete a flow rule by device ID and flow ID.

Expected result:
- REST-created flow rules enforce the requested traffic behaviors correctly.
- The rule-priority and override behavior is explained correctly.
- Generic flow-query and flow-deletion utilities work beyond a single fixed topology.

## Evidence Required
- App activation log (all required apps active)
- Per-rule explanation and flow-table evidence
- Rule priority hierarchy explanation
- Connectivity and isolation evidence for the sliced topology
- Evidence for the second isolation approach
- One short summary paragraph of lessons learned from OpenFlow priority handling
- Device, host, link, flow, and intent query outputs for Task 2
- REST API request or script output for Task 3 rule creation, listing, and deletion

## How to Run
```bash
# Setup
bash check.sh

# Task 1
# Follow Task1_Flow_Rule_Creation/TASK.md for the predefined topology,
# manual OVS flow rules, and sliced-topology requirements.

# Task 2
# Activate apps and complete the ONOS RESTful API tasks as part of Task 2.
# Follow Task2_ONOS_REST_API_Management/TASK.md for the ONOS RESTful API tasks.

# Task 3
# Use the ONOS REST client to create, list, and delete OpenFlow rules.
# Follow Task3_OpenFlow_REST_Orchestration/TASK.md for the REST-based flow orchestration tasks.

# Cleanup
bash cleanup_all.sh
```

## Grading Checklist
- [ ] All required ONOS apps activated and verified active
- [ ] Rule 2 (ICMP block) drops ICMP packets (tcpdump shows block)
- [ ] Rule 3 (block all to Red) installed successfully
- [ ] Rule 4 (allow) overrides previous blocks via priority (not deletion)
- [ ] Rule 6 (HTTP/HTTPS only) permits 80/443, drops others
- [ ] Priority reasoning explained (why higher priority wins)
- [ ] Sliced topology with 5 switches and 10 hosts is created
- [ ] Red and Blue slices are isolated successfully
- [ ] A second isolation approach is demonstrated
- [ ] REST-based mirror, block, allow, and HTTP/HTTPS-only rules are created successfully
- [ ] Generic flow listing by device ID and application ID works correctly
- [ ] Flow deletion by device ID and flow ID works correctly
- [ ] All evidence collected and documented

## Task Folders
- `Task1_Flow_Rule_Creation/` → `TASK.md`, `ANSWER_TEMPLATE.md`
- `Task2_ONOS_REST_API_Management/` → `TASK.md`, `ANSWER_TEMPLATE.md`, `application_list.txt`
- `Task3_OpenFlow_REST_Orchestration/` → `TASK.md`, `ANSWER_TEMPLATE.md`, `task.sh`, `application.txt`





