#!/usr/bin/env bash
# check_onos.sh — Validate ONOS reachability
# Usage: source ./check_onos.sh  OR  bash ./check_onos.sh

check_onos() {
    local host="${ONOS_HOST:-127.0.0.1}"
    local port="${ONOS_PORT:-8181}"
    local user="${ONOS_USER:-onos}"
    local pass="${ONOS_PASS:-rocks}"
    local url="http://${host}:${port}/onos/v1/applications"

    echo "=== Checking ONOS ==="
    echo "  Connecting to ${host}:${port} ..."

    if ! command -v curl &>/dev/null; then
        echo "  [FAIL] 'curl' not found."
        return 1
    fi

    if curl -sf -u "${user}:${pass}" "$url" -o /dev/null 2>/dev/null; then
        echo "  [OK]   ONOS REST API reachable at http://${host}:${port}"
        return 0
    else
        echo "  [FAIL] Cannot reach ONOS at http://${host}:${port}"
        echo "         Check that ONOS is running and credentials are correct."
        echo "         Override with: ONOS_HOST=<ip> ONOS_PORT=<port> $0"
        return 1
    fi
}

# Run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_onos
    exit $?
fi
