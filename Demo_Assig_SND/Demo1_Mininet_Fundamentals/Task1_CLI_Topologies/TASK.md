# Task 1 — Mininet CLI Topologies with Local and Remote Controllers

## Objective
Use the Mininet CLI to create several standard topologies, first with the OpenFlow reference controller and then with the remote ONOS controller configured in Task0.

## Part 1 — OpenFlow Reference Controller

Create the following topologies using the Mininet CLI and the OpenFlow reference controller:

1. A single-switch topology with 10 hosts.
2. A linear topology with 5 switches and 5 hosts.
3. A tree topology with depth 3 and fanout 2.

## Part 2 — Remote SDN Controller (ONOS)

Repeat the same three topology creation tasks, but this time connect Mininet to the remote ONOS controller installed earlier.

## Student Work

For each topology in Part 1 and Part 2, students must provide:

- The exact Mininet command used.
- A brief explanation of what the command creates.
- Basic validation evidence showing that the topology started correctly.

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
- In this CLI-based task, explicitly pass the switch protocol when launching Mininet.
- If your topology contains multiple switches, make sure every switch uses an explicit protocol setting.

## Hints

- Use the Mininet CLI topology options for `single`, `linear`, and `tree`.
- For Part 1, use the OpenFlow reference controller option.
- For Part 2, use the remote controller option and specify the ONOS IP address and OpenFlow port.
- If ONOS is running on another machine, replace `127.0.0.1` with the controller IP address.
- You may use `mn --help` to discover the required syntax yourself.

## Validation

After starting each topology, use Mininet CLI commands such as:

```bash
nodes
net
pingall
```

For the ONOS-based runs, students may also verify discovery in the ONOS UI or with the REST API.

## Expected Results

- Each topology starts successfully without errors.
- The correct number of switches and hosts appears in Mininet.
- `pingall` shows expected end-to-end reachability.
- ONOS-based runs appear in the ONOS topology view after discovery completes.

## Submission

- Commands used for all six runs.
- A brief explanation for each command.
- Validation evidence such as `nodes`, `net`, `pingall`, or ONOS UI/API observations.
- Short troubleshooting notes if any run failed before being fixed.


