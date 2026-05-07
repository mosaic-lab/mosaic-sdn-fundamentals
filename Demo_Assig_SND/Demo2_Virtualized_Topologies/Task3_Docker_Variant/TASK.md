# Task 2.4 (Optional) — Docker Variant

## Objective
Repeat Task 2.1 and Task 2.2 using Docker containers.

## Task

Assuming you have understood how Linux containers work, repeat Task 2.1 and Task 2.2 using Docker containers.

## Student Work

For this optional task, students must:

- Create the corresponding Python or script file inside `Task3_Docker_Variant/`.
- Recreate the fixed leaf-spine topology from Task 2.1 using Docker containers.
- Recreate the automation logic from Task 2.2 using Docker containers.
- Validate the created topology and connectivity.

## Important Note

> [!IMPORTANT]
> This task is optional.
> Clean up the previous topology before rerunning the Docker-based version to avoid conflicts with existing bridges, links, namespaces, or containers.

## Validation

After creating the topology, validate the result with evidence such as:

```bash
docker ps
ovs-vsctl show
ping
```

Students should also verify that the Docker-based topology appears correctly in ONOS.

## Submission

- The Python code or script created in `Task3_Docker_Variant/`.
- A brief explanation of how Task 2.1 and Task 2.2 were repeated with Docker.
- Validation evidence for topology creation and connectivity.
- Short troubleshooting notes.
