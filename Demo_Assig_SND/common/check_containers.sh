#!/usr/bin/env bash
# check_containers.sh — Validate LXC/LXD installation
# Usage: source ./check_containers.sh  OR  bash ./check_containers.sh

check_containers() {
    echo "=== Checking LXC/LXD ==="
    local ok=0

    if command -v lxc-ls &>/dev/null; then
        echo "  [OK]   LXC found: $(lxc-ls --version 2>/dev/null || echo 'version unknown')"
    else
        echo "  [WARN] LXC not found. Install with: sudo apt-get install lxc"
        ok=1
    fi

    if command -v lxc &>/dev/null; then
        local lxd_ver
        lxd_ver=$(lxc --version 2>/dev/null || echo 'version unknown')
        echo "  [OK]   LXD client found: $lxd_ver"

        if lxc list &>/dev/null; then
            echo "  [OK]   LXD daemon is reachable."
        else
            echo "  [WARN] LXD daemon not reachable. Try: sudo snap start lxd"
            ok=1
        fi
    else
        echo "  [WARN] LXD client ('lxc') not found. Install with: sudo snap install lxd"
        ok=1
    fi

    return $ok
}

# Run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_containers
    exit $?
fi
