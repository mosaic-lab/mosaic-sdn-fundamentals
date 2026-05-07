#!/bin/bash
# Template check.sh for Demo2

set -e

echo "=== Demo2 Pre-Lab Checks ==="
echo ""

# Check if Mininet is installed (for topologies)
if ! command -v mn &> /dev/null; then
    echo "❌ Mininet not found. Please install Mininet first."
    exit 1
fi

echo "✓ Mininet installed"

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found."
    exit 1
fi

echo "✓ Python3 available"

# Check container support (at least one must be available)
if command -v docker &> /dev/null; then
    echo "✓ Docker available"
fi

if command -v lxc &> /dev/null; then
    echo "✓ LXC available"
fi

if command -v lxd &> /dev/null; then
    echo "✓ LXD available"
fi

# Check for veth/namespace support
if [ -d /sys/class/net ]; then
    echo "✓ Linux network namespace support available"
fi

echo ""
echo "Ready to start Demo2!"
echo "Run: bash run_demo.sh"
