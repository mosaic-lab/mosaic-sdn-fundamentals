# ONOS and Linux Containers

## Objective
Build and automate a leaf-spine topology using Linux containers and compare this approach with the namespace-based work from Demo 1.

## Background

This assignment contains two examples using two different Linux container implementations, namely LXC and LXD, while targeting the same topology behavior and output.

Both example scripts create a simple topology where two switches are connected together and each switch is connected to one host. In the ONOS GUI, a host is represented by either an LXC or an LXD container. This provides a simple way to build infrastructure-layer components with containers.

## Task 2.1 — Leaf-Spine Topology

Create a leaf-spine topology where:

- the number of leaf switches is 8
- the number of spine switches is 3
- each leaf node contains 2 Linux containers

A leaf-spine topology is a two-layer topology composed of leaf switches and spine switches. Each switch in the spine layer is connected to all leaf switches.

Use LXC when the leaf number is odd and use LXD when the leaf number is even.

## Task 2.2 — Automation

Automate Task 2.1 so that the final code asks for the number of leaves, spine switches, and host nodes, and then generates the expected topology automatically.

## Task 2.3 — Short Discussion

Compared to namespaces from Demo 1, do you find manipulating low-level containers harder to implement and understand or not? Briefly explain why.

## Student Work

For this task, students must:

- Create the corresponding Python or script file inside `Task2_ONOS_and_Linux_Containers/`.
- Implement Task 2.1 and Task 2.2.
- Answer the Task 2.3 discussion question.
- Validate the created topology and its connectivity.

## Important Note

> [!IMPORTANT]
> Clean up the previous topology before rerunning the task.
> Existing bridges, links, namespaces, or containers may cause conflicts during the next run.

## Validation

After creating the topology, validate the result with evidence such as:

```bash
ovs-vsctl show
lxc-ls
lxc list
ping
```

Students should also verify that the topology appears correctly in ONOS.

## Submission

- The Python code or script created in `Task2_ONOS_and_Linux_Containers/`.
- A brief explanation of the implementation for Task 2.1 and Task 2.2.
- The written answer for Task 2.3.
- Validation evidence for topology creation and connectivity.
- Short troubleshooting notes.
