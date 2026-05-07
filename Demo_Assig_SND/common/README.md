# Common Shared Utilities

This folder contains reusable environment checks, cleanup scripts, and ONOS initialisation helpers shared across all demos.

## Purpose

Use this folder for three common tasks:
- pre-flight environment validation before a demo starts
- topology or controller cleanup before reruns
- ONOS app initialisation after a reset

## Files

### Validation Scripts

- `check_mininet.sh` — validate Mininet installation
- `check_onos.sh` — validate ONOS reachability
- `check_docker.sh` — validate Docker installation
- `check_containers.sh` — validate LXC/LXD installation

These scripts are typically sourced or called by each demo's `check.sh`.

### Cleanup Scripts

- `topology_cleanup.sh` — remove lab-created topology state on the host, including namespaces, OVS bridges, and veth interfaces
- `onos_cleanup.sh` — remove stale ONOS-side device state through the REST API when devices remain visible after teardown
- `clean_all.sh` — perform a full reset of both topology state and ONOS runtime state; supports broader rerun cleanup than the narrower scripts above

### ONOS Initialisation

- `onos_init_apps.sh` — activate the default ONOS apps needed for the teaching demos after a cleanup or controller restart

## Typical Usage

- run `check_*.sh` before a lab when you need to verify prerequisites
- run `topology_cleanup.sh` when only host-side topology state is stale
- run `onos_cleanup.sh` when ONOS still shows stale devices or elements
- run `clean_all.sh` when both topology state and ONOS state need a clean reset
- run `onos_init_apps.sh` after a reset so ONOS can rediscover and display topology elements correctly
