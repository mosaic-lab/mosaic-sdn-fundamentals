#!/usr/bin/env bash
# onos_init_apps.sh — Activate required ONOS apps after a clean_all reset
#
# Usage:
#   bash ./onos_init_apps.sh                    # activate default app set
#   bash ./onos_init_apps.sh org.onosproject.fwd org.onosproject.proxyarp
#   ONOS_HOST=192.168.1.10 bash ./onos_init_apps.sh
#
# Default app set covers basic Mininet + ONOS demos (Assignment 1.1 etc.):
#   openflow, openflow-base, drivers, lldpprovider, hostprovider, gui2, fwd
#
# Override the list by passing app names as arguments.

# ── Config ────────────────────────────────────────────────────────────────────
ONOS_HOST="${ONOS_HOST:-127.0.0.1}"
ONOS_PORT="${ONOS_PORT:-8181}"
ONOS_USER="${ONOS_USER:-onos}"
ONOS_PASS="${ONOS_PASS:-rocks}"
BASE_URL="http://${ONOS_HOST}:${ONOS_PORT}/onos/v1"
AUTH="${ONOS_USER}:${ONOS_PASS}"

# Default apps needed for basic OpenFlow + Mininet demos
# - openflow / openflow-base : OpenFlow device connection
# - drivers                  : device drivers and pipeconf support for OVS/OF devices
# - lldpprovider             : link discovery (shows links in UI)
# - hostprovider             : host discovery (shows hosts in UI)
# - gui2                     : ONOS topology UI component used in the web UI
# - fwd                      : reactive forwarding (enables pingall)
DEFAULT_APPS=(
    "org.onosproject.openflow"
    "org.onosproject.openflow-base"
    "org.onosproject.drivers"
    "org.onosproject.lldpprovider"
    "org.onosproject.hostprovider"
    "org.onosproject.gui2"
    "org.onosproject.fwd"
)

# Use args if provided, else fall back to defaults
if [[ $# -gt 0 ]]; then
    APPS=("$@")
else
    APPS=("${DEFAULT_APPS[@]}")
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
onos_post() { curl -sf -u "${AUTH}" -X POST "${BASE_URL}${1}" -o /dev/null 2>/dev/null; }
onos_get()  { curl -sf -u "${AUTH}" -H "Accept: application/json" "${BASE_URL}${1}"; }

onos_reachable() {
    curl -sf -u "${AUTH}" "${BASE_URL}/applications" -o /dev/null 2>/dev/null
}

app_state() {
    # prints ACTIVE / INSTALLED / unknown
    onos_get "/applications/${1}" 2>/dev/null | \
        python3 -c "import sys,json; print(json.load(sys.stdin).get('state','unknown'))" 2>/dev/null \
        || echo "unknown"
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo ""
echo "=========================================="
echo "    ONOS App Initialisation"
echo "=========================================="
echo ""

echo "=== Checking ONOS reachability ==="
MAX_WAIT=30
ELAPSED=0
until onos_reachable || [[ $ELAPSED -ge $MAX_WAIT ]]; do
    echo "    Waiting for ONOS at ${BASE_URL} ... (${ELAPSED}s)"
    sleep 3
    ELAPSED=$((ELAPSED + 3))
done

if ! onos_reachable; then
    echo "  [FAIL] ONOS not reachable at ${BASE_URL} after ${MAX_WAIT}s. Aborting."
    exit 1
fi
echo "  [OK]   ONOS is reachable."
echo ""

echo "=== Activating apps ==="
FAILED=0
for app in "${APPS[@]}"; do
    state=$(app_state "$app")
    if [[ "$state" == "ACTIVE" ]]; then
        echo "  [skip] already ACTIVE  : $app"
        continue
    fi

    echo -n "  [act]  activating      : $app ... "
    if onos_post "/applications/${app}/active"; then
        sleep 1
        new_state=$(app_state "$app")
        if [[ "$new_state" == "ACTIVE" ]]; then
            echo "OK"
        else
            echo "state=${new_state} (may still be starting)"
        fi
    else
        echo "FAILED"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=== Final app status ==="
for app in "${APPS[@]}"; do
    state=$(app_state "$app")
    if [[ "$state" == "ACTIVE" ]]; then
        echo "  [OK]   $app"
    else
        echo "  [WARN] $app  (state: $state)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo "=========================================="
    echo "    All apps active. ONOS is ready."
    echo "=========================================="
    exit 0
else
    echo "=========================================="
    echo "    WARNING: $FAILED app(s) not active."
    echo "=========================================="
    exit 1
fi
