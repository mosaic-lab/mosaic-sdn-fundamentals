# Task 2 — Python API Topologies with ONOS

## Objective
Create Mininet topologies using the Python API and connect them to the ONOS SDN controller.

## Task

Create the following topologies using the Python API interface and the ONOS SDN controller:

1. A single-switch topology with 13 hosts.
2. A linear topology with 10 switches and 10 hosts.
3. A tree topology with depth 3 and fanout 2.

## Implementation Notes

- You are free to mix API levels: low-level, mid-level, or high-level APIs.
- You may use one API level throughout or combine multiple levels where appropriate.
- Your code should be clearly structured, documented, and follow good Python programming practice.
- Create the corresponding Python or script files inside this task folder: `Task2_Python_API_Topologies/`.

## Student Work

For each topology, students must provide:

- The Python file or script created inside `Task2_Python_API_Topologies/` and used to create the topology.
- A brief explanation of the design approach.
- Validation evidence showing that the topology started correctly and connected to ONOS.

## Important Note

> [!IMPORTANT]
> Before running the task, confirm which OpenFlow version(s) are supported by your ONOS setup.
> You must explicitly set the protocol version on every switch.
> ONOS may silently ignore switches that connect with a version it does not recognise.

How to check and use the version:

- Check the course guide, your ONOS setup notes, or the official ONOS/Open vSwitch documentation.
- In this teaching setup, start by using `protocols='OpenFlow13'` as the recommended configuration.
- After starting a small test topology, verify whether the switch appears in the ONOS UI or via the ONOS REST API.
- On the Mininet/OVS side, inspect the configured bridge protocol with a command such as `sudo ovs-vsctl get bridge s1 protocols`.
- In this Python API task, explicitly set the protocol on every switch when creating it.
- If your topology contains multiple switches, make sure every switch uses an explicit protocol setting.

## Validation

After running each script, validate the result with appropriate evidence such as:

```bash
nodes
net
pingall
```

Students should also verify that the topology is visible from ONOS through the Web UI or REST API.

## Expected Results

- Each Python topology runs without errors.
- The required number of hosts and switches is created.
- End-to-end connectivity works as expected.
- ONOS discovers the devices, links, and hosts after the topology starts.

## Submission

- Python code or scripts for all three topology tasks, stored in `Task2_Python_API_Topologies/`.
- A brief explanation for each implementation.
- Validation evidence from Mininet and ONOS.
- Short troubleshooting notes if any issues were encountered and fixed.
