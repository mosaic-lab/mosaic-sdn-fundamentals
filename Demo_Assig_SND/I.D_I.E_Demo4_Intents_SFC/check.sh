#!/bin/bash
# Template check.sh for Demo4

set -e

echo "=== Demo4 Pre-Lab Checks ==="
echo ""

# Check Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found."
    exit 1
fi

echo "✓ Python3 available"

# Check if requests and other packages are available
python3 -c "import requests" 2>/dev/null || {
    echo "⚠ Warning: requests library not found. Install: pip3 install requests"
}

echo "✓ Python requests available"

# Check tcpdump (needed for path observation)
if ! command -v tcpdump &> /dev/null; then
    echo "⚠ Warning: tcpdump not found. Needed for evidence collection."
    echo "  Install: sudo apt-get install tcpdump"
fi

echo "✓ tcpdump available (or can be installed)"

# Check ONOS connectivity
ONOS_URL="http://${ONOS_HOST:-127.0.0.1}:${ONOS_PORT:-8181}/onos/v1"
echo "Checking ONOS at $ONOS_URL..."

if curl -s -u onos:rocks "$ONOS_URL/devices" > /dev/null 2>&1; then
    echo "✓ ONOS controller reachable"
else
    echo "⚠ Warning: Cannot reach ONOS at $ONOS_URL"
    echo "  Ensure ONOS is running and accessible"
fi

echo ""
echo "Ready to start Demo4!"
echo "Run: python3 task1.py"
