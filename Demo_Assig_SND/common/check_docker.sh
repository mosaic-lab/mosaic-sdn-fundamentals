#!/usr/bin/env bash
# check_docker.sh — Validate Docker installation
# Usage: source ./check_docker.sh  OR  bash ./check_docker.sh

check_docker() {
    echo "=== Checking Docker ==="

    if ! command -v docker &>/dev/null; then
        echo "  [FAIL] 'docker' not found. Install Docker:"
        echo "         https://docs.docker.com/engine/install/"
        return 1
    fi

    echo "  [OK]   docker found: $(docker --version)"

    if ! docker info &>/dev/null; then
        echo "  [FAIL] Docker daemon not running or no permission."
        echo "         Try: sudo systemctl start docker"
        echo "         Or add your user to the docker group: sudo usermod -aG docker \$USER"
        return 1
    fi

    echo "  [OK]   Docker daemon is running."
    return 0
}

# Run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_docker
    exit $?
fi
