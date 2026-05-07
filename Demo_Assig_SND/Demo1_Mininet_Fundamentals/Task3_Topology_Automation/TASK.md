# Task 3 — Topology Automation

## Objective
Automate the topology creation work from Task 2 so that a topology can be created from the topology type and its specifications.

## Task

Try to automate Task 2 so that you can create a topology given:

1. the topology type, such as `tree` or `linear`
2. the specifications required for that type

## Student Work

For this task, students must:

- Create the corresponding Python or script file inside `Task3_Topology_Automation/`.
- Implement an automation method that accepts the topology type and its parameters.
- Demonstrate at least one linear topology and one tree topology.
- Clean the previous topology before running the next one.

## Important Note

> [!IMPORTANT]
> Remember to clean out the previous topology before executing the automation task.
> Otherwise, errors may occur because of existing links, bridges, namespaces, or stale state.

## Validation

After generating each topology, validate the result with evidence such as:

```bash
nodes
net
pingall
```

If ONOS is used as the controller, students should also verify the topology in the ONOS UI or REST API.

## Submission

- The Python code or script created in `Task3_Topology_Automation/`.
- A brief explanation of how the automation accepts topology type and parameters.
- Validation evidence for at least two generated topologies.
- Short troubleshooting notes.
