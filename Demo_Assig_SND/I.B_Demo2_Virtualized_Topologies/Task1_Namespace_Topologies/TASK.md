# Task 1 — Namespace Topologies

## Objective
Create virtualized topologies using Linux network namespaces and automate their generation from topology parameters.

## Background

The shell script `basic-net-ns.sh` contains a set of shell functions to create a simple topology where two switches are connected together and each switch is connected to one host. In this assignment, a host is represented by a network namespace. This provides a simple way to create infrastructure-layer components.

You may use this approach as inspiration for your own implementation.

## Task 1.1 — Linear Topology

Create a linear topology of 5 switches and 5 hosts.

In a linear topology, each switch has two connections with other switches except the first and the last ones.

To do this, you may write either a shell script or a Python-based program. Your code should be well commented and follow clear coding and naming conventions.

## Task 1.2 — Tree Topology

Create a tree topology with depth 3 and fanout 2.

In a tree topology, the depth refers to the number of layers in the tree and the fanout refers to the number of children each node has.

## Task 1.3 — Topology Automation

Try to automate the previous tasks so that you can create a topology given:

1. the topology type, such as `tree` or `linear`
2. the specifications for that type, such as depth and fanout for a tree or the number of switches for a linear topology

Python is preferred for the automation task because of the available tools that simplify networking-related logic.

## Student Work

For this task, students must:

- Create the corresponding shell script or Python file inside `Task1_Namespace_Topologies/`.
- Implement Task 1.1 and Task 1.2.
- Implement Task 1.3 to automate topology generation.
- Validate topology creation, addressing, and connectivity.

## Important Note

> [!IMPORTANT]
> Remember to clean up the previous topology before creating a new one.
> Otherwise, overlapping links, namespaces, or interfaces may cause errors.

## Validation

After creating each topology, validate the result with evidence such as:

```bash
ip netns list
ovs-vsctl show
ping
```

## Submission

- The shell script or Python files created in `Task1_Namespace_Topologies/`.
- A brief explanation of the implementation for Task 1.1, Task 1.2, and Task 1.3.
- Validation evidence for topology creation and connectivity.
- Short troubleshooting notes.
