#!/usr/bin/env bash
# check_mininet.sh — Validate Mininet installation
# Usage: source ./check_mininet.sh  OR  bash ./check_mininet.sh

check_mininet() {
    echo "=== Checking Mininet ==="

    if ! command -v mn &>/dev/null; then
        echo "  [FAIL] 'mn' not found. Install Mininet:"
        echo "         sudo apt-get install mininet"
        return 1
    fi

    local version
    version=$(mn --version 2>&1 | head -1)
    echo "  [OK]   mn found: $version"

    if ! command -v ovs-vsctl &>/dev/null; then
        echo "  [FAIL] Open vSwitch not found. Install with:"
        echo "         sudo apt-get install openvswitch-switch"
        return 1
    fi

    echo "  [OK]   Open vSwitch: $(ovs-vsctl --version | head -1)"
    return 0
}

# Run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_mininet
    exit $?
fi
