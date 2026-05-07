# SDN Hardware Testbed Student Guide

## Overview

In this project, you will build a physical SDN testbed using commodity PCs running Open vSwitch (OVS), ONOS as the SDN controller, and Raspberry Pis as end hosts. You are not expected to finish everything at once. Instead, you will work stage by stage and show what your team can make run.

Each teaching switch is mapped to a dedicated physical PC, and Raspberry Pis connect to edge switches through direct physical Ethernet links.

You should keep the **control plane** and the **data plane** separate:
- the **management/control network** carries ONOS, SSH, REST API, and administration traffic;
- the **data plane** carries forwarding traffic between OVS switches and Raspberry Pis.

For the physical deployment, each OVS PC should have **at least 3 NICs**:
- `eth0` for management/control,
- `eth1` for data-plane link 1,
- `eth2` for data-plane link 2.

You can add more NICs later if your team wants to support a larger topology or more service experiments.

---

## 1. Basic Resource Plan

| Device | Management IP | Role | Notes |
|--------|-----------|------|-------|
| PC1 | 192.168.1.1 | ONOS Controller | 16 GB RAM recommended; 1 management NIC is enough |
| PC2 | 192.168.1.2 | OVS Node / sw1 | minimum 3 NICs: 1 management + 2 data |
| PC3 | 192.168.1.3 | OVS Node / sw2 | minimum 3 NICs: 1 management + 2 data |
| PC4 | 192.168.1.4 | OVS Node / sw3 | minimum 3 NICs: 1 management + 2 data |
| PC5 | 192.168.1.5 | OVS Node / sw4 | minimum 3 NICs: 1 management + 2 data |
| RPi1 | optional separate mgmt or none | End Host H1 | experiment traffic on `eth0`; optional Wi-Fi/admin path |
| RPi2 | optional separate mgmt or none | End Host H2 | experiment traffic on `eth0` |
| RPi3 | optional separate mgmt or none | End Host H3 | experiment traffic on `eth0` |
| RPi4 | optional separate mgmt or none | End Host H4 | experiment traffic on `eth0` |

> If your team uses more Raspberry Pis, follow the same pattern. If you need separate management access, assign management addresses on the admin network. Otherwise, keep only experiment-side addressing on `eth0`.

### Two-Layer Network Design

```
Management Network  (eth0, 192.168.1.x)  — all devices on a shared unmanaged switch
Data Plane          (physical only)       — inter-switch links (see Section 5)
```

### Recommended NIC Allocation

| Device Type | Interface | Purpose | IP Recommendation |
|------------|-----------|---------|-------------------|
| ONOS PC | `eth0` | ONOS GUI, REST, SSH | static IP on management subnet |
| OVS PC | `eth0` | controller reachability, SSH, updates | static IP on management subnet |
| OVS PC | `eth1` | data-plane uplink/downlink | no IP if used as pure OVS port |
| OVS PC | `eth2` | second data-plane uplink/downlink or RPi-facing port | no IP if used as pure OVS port |
| RPi | `eth0` | host traffic in the experiment | assign experiment IP only |
| RPi | `wlan0` / USB NIC (optional) | management/admin access | optional, separate from experiment traffic |

Follow these basic rules:
- Keep `eth0` outside OVS bridges.
- Add `eth1`, `eth2`, and other data NICs to OVS as switch ports.
- Do not assign normal host IP addresses to data NICs unless your experiment explicitly requires Layer-3 functions on the Linux host.

---

## 2. Software Baseline

### PC1 — ONOS Controller

For the initial deployment, you should reuse the Docker-based controller workflow from `SDN_Lab_Setup_Guide_0.md`.

```bash
# Install Docker if needed
sudo apt update
sudo apt install -y docker.io curl
sudo systemctl enable --now docker

# Start ONOS in Docker
docker run -d \
  --name onos \
  --restart unless-stopped \
  -p 6653:6653 \
  -p 8181:8181 \
  -p 8101:8101 \
  onosproject/onos:2.7-latest

# Verify the controller is up
curl -u onos:rocks http://localhost:8181/onos/v1/devices

# Activate required apps (after ONOS boots)
ssh -p 8101 karaf@localhost
# Password: karaf
# app activate org.onosproject.openflow
# app activate org.onosproject.fwd
# app activate org.onosproject.lldpprovider
# app activate org.onosproject.hostprovider
```

Notes for your team:
- Enable `hostprovider` from Stage 1 so ONOS can show endpoint discovery automatically in later stages.
- In Stage 3 and Stage 4, you can reuse ONOS REST APIs for `/devices`, `/links`, and `/hosts` rather than building everything from scratch.
- Open TCP ports `6653`, `8181`, and `8101` on the ONOS PC if the host firewall is enabled.
- Treat the Docker-based bootstrap as the standard controller setup for this project.

### PC2 – PC5 — OVS Nodes

```bash
sudo apt update
sudo apt install -y openvswitch-switch openvswitch-common \
                   net-tools iperf3 tcpdump iproute2

# Verify
sudo ovs-vsctl show
sudo systemctl enable openvswitch-switch
```

Notes for your team:
- Reserve `eth0` for management only.
- Leave `eth1`, `eth2`, etc. unnumbered if they are used as switch ports.
- If netplan or NetworkManager auto-assigns addresses to data-plane NICs, disable that behavior.
- Label each NIC and cable physically before class deployment.

### Raspberry Pis — End Hosts

```bash
sudo apt update
sudo apt install -y iperf3 vlc ffmpeg tcpdump net-tools
```

---

## 3. Physical Link Rules

> Your design decision for this project is simple: connect OVS bridges across different PCs using dedicated physical Ethernet links only.

### Dedicated Physical Cables

Each inter-PC logical link should use a separate physical NIC and a direct Ethernet cable (or patch through an unmanaged switch).

```
PC2 eth1 ──[ CAT6 cable ]──► PC3 eth1
  (added to sw2)                (added to sw3)
```

Why you are doing this:
- the data plane stays physically separated from the control plane;
- the behavior is closer to a real network;
- your demos are easier to explain because the links are real.

In practice:
- keep `eth0` for management/control only,
- use physical NICs for all switch-to-switch data links,
- use physical NICs for all Raspberry Pi to edge-switch links.

---

## 4. Stage Roadmap

You will complete this project in stages. The goal is not to make every stage perfect. The goal is to get each stage working well enough to demonstrate it clearly.

### Stage 1: Linear Physical Topology

This is your baseline topology. Get this working first before trying anything more ambitious.

How to start:
- first complete the single-controller and single-switch validation process from `SDN_Lab_Setup_Guide_0.md`;
- then replicate the same single-switch pattern across four OVS PCs with unique Datapath IDs;
- do not move to Stage 2 until your team can repeat the Stage 1 setup reliably.

```
RPi1 ===== sw1 ===== sw2 ===== sw3 ===== sw4 ===== RPi2
     [PC2]     [PC3]     [PC4]     [PC5]

===== means a direct physical Ethernet link
```

What you should achieve in Stage 1:
- all inter-PC links use physical Ethernet only;
- each switch is implemented by a dedicated physical PC;
- Raspberry Pis act as traffic endpoints and application hosts;
- ONOS provides switch discovery, topology view, and flow control;
- the setup must support repeatable `ping`, `iperf3`, and video-stream demonstrations.

Suggested device set:
- PC1: ONOS controller
- PC2: OVS node hosting `sw1`
- PC3: OVS node hosting `sw2`
- PC4: OVS node hosting `sw3`
- PC5: OVS node hosting `sw4`
- RPi1 and RPi2: application endpoints

Suggested cable plan:
- all `eth0` interfaces connect to the management switch;
- `PC2 eth1 <-> PC3 eth1` provides the `sw1 <-> sw2` data-plane link;
- `PC3 eth2 <-> PC4 eth1` provides the `sw2 <-> sw3` data-plane link;
- `PC4 eth2 <-> PC5 eth1` provides the `sw3 <-> sw4` data-plane link;
- `PC2 eth2 <-> RPi1 eth0` attaches the first endpoint physically to `sw1`;
- `PC5 eth2 <-> RPi2 eth0` attaches the second endpoint physically to `sw4`.

Practical setup rule:
- use the bridge configuration pattern from `SDN_Lab_Setup_Guide_0.md` as the first VSwitch setup;
- after one switch is confirmed in ONOS, replicate the same bridge/controller pattern on the remaining OVS PCs with different Datapath IDs;
- then add the physical inter-PC links required by the linear topology.

What success looks like:
- ONOS discovers all four switches and all three inter-switch links;
- `iperf3` succeeds end to end between the two RPis;
- a video stream can be sent from RPi1 to RPi2 through the OVS fabric;
- link bandwidth can be limited with `tc` on any physical inter-switch link.

### Stage 2: DAG Topology for Dual SFC Paths

In Stage 2, your team should build a DAG-style forwarding structure that supports two parallel service paths across four Raspberry Pis.

Recommended target topology:

```
RPi1 =====\
           \
            sw1 ===== sw2 =====\
           /  \                 \
RPi2 =====/    \===== sw3 ======= sw4 ===== RPi3
                                  \
                                   ===== RPi4
```

How to read this topology:
- `sw1` appears only once as the shared ingress edge switch for both source RPis;
- `sw2` and `sw3` act as two parallel service branches;
- `sw4` acts as the egress aggregation switch and forwards traffic to two destination RPis.

What your team is doing in this stage:
- reuse the four physical switch PCs from Stage 1;
- re-cable the Stage 1 linear topology into a branching DAG topology;
- add two additional Raspberry Pis so that four endpoints are available at the same time;
- use the two parallel branches to host two independent SFC policies for different traffic classes.

Suggested device set:
- reuse PC1 to PC5 from Stage 1;
- reuse RPi1 and RPi2 as source endpoints;
- add RPi3 and RPi4 as destination endpoints;
- add extra USB NICs on the ingress and egress switch PCs because `sw1` and `sw4` each need four data-plane ports.

Suggested cable plan:
- `PC2` hosts `sw1` and connects physically to `RPi1`, `RPi2`, `PC3`, and `PC4`;
- `PC3` hosts `sw2` and connects physically to `PC2` and `PC5`;
- `PC4` hosts `sw3` and connects physically to `PC2` and `PC5`;
- `PC5` hosts `sw4` and connects physically to `PC3`, `PC4`, `RPi3`, and `RPi4`.

What you can demonstrate in this stage:
- build two parallel traffic paths with different bandwidth profiles;
- install two different SFC policies, one per branch;
- compare service-aware forwarding behavior across two business flows;
- demonstrate DAG-style path selection without building a full mesh or tree.

Example SFC mapping:
- SFC A: `RPi1 -> sw1 -> sw2 -> sw4 -> RPi3`
- SFC B: `RPi2 -> sw1 -> sw3 -> sw4 -> RPi4`

Keep these limits in mind:
- the topology remains physically cabled end to end;
- the graph must remain acyclic for the intended forwarding demos;
- no full ring, no full tree, and no fat-tree are required.

### Stage 3: ONOS UI Visibility and Scripted Control

In Stage 3, you should use ONOS itself for visualization and control before trying to build your own dashboard.

What you should achieve in Stage 3:
- operate an already deployed Stage 1 or Stage 2 topology rather than building a new topology;
- verify that devices, links, and hosts are discovered consistently by ONOS;
- support flow adjustment through the ONOS CLI, REST API, or local automation scripts;
- support SFC-related control through repeatable command-line or script-driven procedures.

Suggested control approach:
- ONOS is the primary visualization plane through its Web UI;
- ONOS CLI and REST APIs are the primary control interfaces for topology inspection and flow operations;
- shell scripts or Python scripts can be used to apply predefined flow rules, intent operations, and SFC-related actions;
- `tc` commands on the switch PCs remain the mechanism for bandwidth control on physical links.

What you should be able to show:
- open the ONOS UI and confirm the already deployed topology is rendered correctly;
- list devices, links, and hosts through ONOS CLI or REST calls;
- add, remove, or modify flows through scripted commands;
- trigger predefined SFC control actions through scripts for the two DAG branches;
- keep an operator runbook for repeatable classroom execution.

### Stage 4: Advanced Custom Dashboard

In Stage 4, your team can build a custom dashboard above ONOS and the physical testbed.

What you should achieve in Stage 4:
- automatically detect ONOS controller state, switches, links, and hosts as they come online;
- visualize the live topology and device status in a custom dashboard;
- observe discovered devices, flows, and service paths through a unified UI;
- create, modify, and remove flows through dashboard actions;
- create, modify, and remove service chains through dashboard actions;
- adjust link- or policy-related configuration from the dashboard while reusing the existing ONOS and OVS control mechanisms.

Suggested architecture:
- ONOS remains the controller and source of truth for topology and flow state;
- the custom backend consumes ONOS REST APIs for devices, links, hosts, flows, and intents;
- the backend may call local scripts or remote automation on switch PCs for bandwidth and host-side configuration tasks;
- the dashboard frontend renders topology, endpoint status, flow state, and SFC state in a unified view.

What you should be able to show:
- automatic online detection for ONOS, switch PCs, and hosts;
- topology graph visualization with node and link status;
- flow creation and deletion from predefined forms or templates;
- chain creation and deletion for the supported Stage 2 DAG service paths;
- configuration adjustment for bandwidth profiles, path selection, and service policies;
- audit log or action history for operator changes.

---

## 5. Stage Tasks

Treat the stages below as your task list. You do not need to implement every possible feature. What matters is that your team can show a working result for the stage goal.

### Stage 1 Task

Goal:
Build the physical linear topology and make sure ONOS can discover the switches and links.

Required outcome:
- ONOS is running in Docker and reachable;
- the physical linear topology is connected and visible in ONOS;
- Raspberry Pi traffic can pass end to end;
- students can show at least one simple traffic test such as `ping`, `iperf3`, or video streaming.

Possible extensions:
- cleaner cabling and labeling;
- additional traffic tests;
- basic bandwidth limiting on one physical link;
- other reasonable improvements or demonstrations.

### Stage 2 Task

Goal:
Build the DAG topology and demonstrate two different service paths across the network.

Required outcome:
- ONOS can discover the DAG topology and attached hosts;
- traffic can traverse both branches of the DAG;
- students can demonstrate two different SFC-style paths or two different business flows.

Possible extensions:
- branch-specific bandwidth settings;
- richer service functions;
- different traffic classes on the two branches;
- other DAG, SFC, or traffic ideas that fit the stage goal.

### Stage 3 Task

Goal:
Use ONOS UI and scripts or command-line tools to observe and control a topology that has already been built in Stage 1 or Stage 2.

Required outcome:
- students reuse a working Stage 1 or Stage 2 topology rather than building a new one;
- students can show the topology in ONOS UI;
- students can inspect devices, links, hosts, or flows through ONOS CLI, REST, or scripts;
- students can adjust flows or SFC behavior and explain the observed result.

Possible extensions:
- reusable scripts for common control actions;
- more advanced flow policies;
- simple automation for repeated experiments;
- other observation or control ideas that build on Stage 1 or Stage 2.

### Stage 4 Task

Goal:
Build a custom dashboard that integrates topology observation and SDN control.

Required outcome:
- the dashboard shows ONOS controller, switches, links, and hosts coming online;
- the dashboard visualizes the current topology;
- students can use the dashboard to create or adjust flows or chains;
- students can use the dashboard to change at least one configuration item and show the effect.

Possible extensions:
- richer topology visualization;
- action history or logs;
- more advanced chain templates or policy controls;
- other dashboard features that improve observation, control, or usability.

---

## 6. Final Demo

Your final evaluation will focus mainly on the quality of your demonstration rather than on implementation detail. You should still be able to explain your design choices, but the main requirement is to show a working system.

In your final demo, you should be ready to:
- show the deployed topology and explain which stage has been completed;
- show ONOS discovering the current devices, links, and hosts;
- generate traffic between Raspberry Pis and explain the observed forwarding behavior;
- demonstrate one control action, such as changing a flow, changing a path, or applying an SFC-related policy;
- if Stage 4 is attempted, demonstrate the custom dashboard observing and controlling the system.

Evaluation principles:
- a correct and understandable demo matters more than implementation complexity;
- your team has room to choose its own scripts, flow logic, SFC design, and dashboard style;
- partial completion is acceptable if you can clearly explain what works, what does not, and what you attempted.
