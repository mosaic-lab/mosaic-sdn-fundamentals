#!/bin/bash
# Template check.sh for Demo3

set -e

echo "=== Demo3 Pre-Lab Checks ==="
echo ""

# Check Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found."
    exit 1
fi

echo "✓ Python3 available"

# Check if requests library is available
python3 -c "import requests" 2>/dev/null || {
    echo "⚠ Warning: requests library not found. Install: pip3 install requests"
}

echo "✓ Python requests available"

# Check ONOS connectivity (if env vars set)
if [ -n "$ONOS_HOST" ]; then
    ONOS_URL="http://${ONOS_HOST}:${ONOS_PORT:-8181}/onos/v1"
    echo "Checking ONOS at $ONOS_URL..."
    
    if curl -s -u onos:rocks "$ONOS_URL/devices" > /dev/null 2>&1; then
        echo "✓ ONOS controller reachable"
    else
        echo "⚠ Warning: Cannot reach ONOS at $ONOS_URL"
        echo "  Set ONOS_HOST and ONOS_PORT, or ensure ONOS is running"
    fi
else
    echo "ℹ ONOS_HOST not set; will use defaults (127.0.0.1:8181)"
fi

echo ""
echo "Ready to start Demo3!"
echo "Start with Task1_Flow_Rule_Creation/TASK.md or Task2_ONOS_REST_API_Management/TASK.md"
