# Task 1 — OpenFlow Flow Tables

## Objective
Create and analyze OpenFlow flow rules on a predefined topology, then build a restricted sliced topology using OVS-based rules.

## Task 1.1 — Predefined Topology and Flow Rules

The file `task3.1_topology.sh` creates the topology corresponding to **Task 3.1 Topology**, where hosts such as Blue, Red, and Green are attached to OVS switches.

## Important Note

> [!WARNING]
> ONOS actively manages the flow table. If ONOS remains connected, it may immediately remove manual `ovs-ofctl` rules that are not managed by ONOS.
> To test manual flow rules safely, temporarily disconnect ONOS from the switches before adding the rules.

Disconnect ONOS from all switches:

```bash
for br in br-1 br-2 br-3; do
	sudo ovs-vsctl set-controller "$br" ""
done
```

After testing, reconnect ONOS:

```bash
for br in br-1 br-2 br-3; do
	sudo ovs-vsctl set-controller "$br" tcp:<ONOS_IP>:6653
done
```

Replace `<ONOS_IP>` with the actual IP address of your ONOS controller in the current environment.

In this task, you are asked to:

1. Create a flow rule to block ICMP traffic from Blue to Red.
2. Create a flow rule to block traffic to Red.
3. Create a flow rule to allow total access to Red from Green and Blue.
4. Answer whether the second flow rule must be deleted before the third one can take effect.
5. Create a flow rule to allow only HTTP and HTTPS traffic to Red.

For each flow rule, provide the rule details and a short explanation.

Use only the OVS command line to enter the flow rules for this part.

## Task 1.2 — Pseudo Network Slice

Create a pseudo network slice based on namespaces and OVS. This corresponds to the **Task 3.2 Scenario** from the original assignment.

1. Create a linear topology with 5 switches and 10 hosts.
2. Each switch should contain two hosts: one for the Red slice and one for the Blue slice.
3. Create two fully isolated slices, Red and Blue, with no shared access.
4. Redo the isolation using a second approach different from the first one.

You may write a shell script or Python-based code. Your solution may use the OVS command line to create the necessary flow rules.

Exploring VLAN-based isolation is encouraged.

## Student Work

For this task, students must:

- Create or complete the required shell script or Python file inside this task folder.
- Enter and explain the required flow rules for Task 1.1.
- Build and validate the sliced topology for Task 1.2.
- Demonstrate two different isolation approaches for Task 1.2.

## Validation

For Task 1.1, collect evidence such as:

```bash
ovs-ofctl dump-flows <bridge>
ping
curl
```

For Task 1.2, collect evidence such as:

```bash
ovs-vsctl show
ip netns list
ping
```

## Submission

- The shell script or Python code used for the task.
- The entered flow rules with explanations.
- Validation evidence for Task 1.1 and Task 1.2.
- A short explanation of whether deletion was required before overriding a blocking rule.
