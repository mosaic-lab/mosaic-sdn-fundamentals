#!/usr/bin/env bash
# task.sh - Demo 4 topology: Service Function Chaining
# Creates three OVS bridges and three Linux network namespaces.
#
# Topology:
#
#   [Red 10.0.0.100]──ovs-1──ovs-2──[Blue :eth0=10.0.0.111]──ovs-3──[Green 10.0.0.113]
#                                         [:eth1=10.0.0.112]
#                                    (SFF: internal Linux bridge)
#
#   Inter-switch links:
#     ovs-1 ↔ ovs-2  (port 1 each)
#     ovs-2 ↔ ovs-3  (port 2 each)
#
#   Host attachments:
#     red       (10.0.0.100) → ovs-1 port 3
#     blue:eth0 (10.0.0.111) → ovs-2 port 3   ← SFF egress / return-ingress
#     blue:eth1 (10.0.0.112) → ovs-2 port 4   ← SFF ingress / return-egress
#     green     (10.0.0.113) → ovs-3 port 3
#
#   SFC forwarding path (Red → Green via Blue):
#     Red → ovs-1(3→1) → ovs-2(1→4) → Blue:eth1 → [br0] → Blue:eth0
#         → ovs-2(3→2) → ovs-3(2→3) → Green
#
# Usage:
#   sudo bash task.sh           # start topology
#   sudo bash task.sh --clean   # remove topology

# ── ONOS controller detection ──────────────────────────────────────────────────
if [[ -z "${ONOS_IP}" ]]; then
    ONOS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
        $(docker ps -q --filter ancestor=onosproject/onos) 2>/dev/null)
    if [[ -z "${ONOS_IP}" ]]; then
        echo "[!] Could not detect ONOS container IP. Falling back to 127.0.0.1"
        ONOS_IP="127.0.0.1"
    fi
fi
ONOS_PORT="${ONOS_PORT:-6653}"

BRIDGES="ovs-1 ovs-2 ovs-3"

# ── Cleanup ────────────────────────────────────────────────────────────────────
cleanup() {
    echo "[*] Cleaning up..."
    for br in $BRIDGES; do
        ovs-vsctl --if-exists del-br $br
    done
    for ns in red blue green; do
        ip netns del $ns 2>/dev/null
    done
    # Remove host veth pairs (bridge side)
    for iface in veth-red-br veth-blue0-br veth-blue1-br veth-green-br; do
        ip link del $iface 2>/dev/null
    done
    # Remove inter-switch veth pairs (one side each)
    for iface in ovs-int12 ovs-int23; do
        ip link del $iface 2>/dev/null
    done
    echo "[*] Done."
}

if [[ "$1" == "--clean" ]]; then
    cleanup
    exit 0
fi

# ── Ensure clean state ─────────────────────────────────────────────────────────
cleanup 2>/dev/null

# ── Root check ─────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "[!] This script must be run as root. Use: sudo bash $0"
    exit 1
fi

# ── Fix bridge-nf-call-iptables (iptables FORWARD DROP blocks ICMP on LXC bridges)
sysctl -qw net.bridge.bridge-nf-call-iptables=0 2>/dev/null || true
sysctl -qw net.bridge.bridge-nf-call-ip6tables=0 2>/dev/null || true

# ── Create OVS bridges with explicit DPIDs ─────────────────────────────────────
declare -A DP_IDS=(
    [ovs-1]="0000000000000001"
    [ovs-2]="0000000000000002"
    [ovs-3]="0000000000000003"
)

for br in $BRIDGES; do
    echo "[*] Creating OVS bridge: $br  (DPID: ${DP_IDS[$br]})"
    ovs-vsctl add-br $br \
        -- set bridge $br other-config:datapath-id=${DP_IDS[$br]} \
        -- set bridge $br protocols=OpenFlow13 \
        -- set-controller $br tcp:${ONOS_IP}:${ONOS_PORT}
done

# ── Inter-switch links ─────────────────────────────────────────────────────────
#
#   ovs-1: port1=ovs1↔ovs2, port3=red
#   ovs-2: port1=ovs2↔ovs1, port2=ovs2↔ovs3, port3=blue:eth0, port4=blue:eth1
#   ovs-3: port2=ovs3↔ovs2, port3=green

_add_link() {
    local br_a=$1 iface_a=$2 port_a=$3 br_b=$4 iface_b=$5 port_b=$6
    echo "[*] Creating inter-switch link: $br_a:$port_a ($iface_a) <--> $br_b:$port_b ($iface_b)"
    ip link add $iface_a type veth peer name $iface_b
    ip link set $iface_a up
    ip link set $iface_b up
    ovs-vsctl add-port $br_a $iface_a -- set Interface $iface_a ofport_request=$port_a
    ovs-vsctl add-port $br_b $iface_b -- set Interface $iface_b ofport_request=$port_b
}

_add_link ovs-1 ovs-int12 1  ovs-2 ovs-int21 1
_add_link ovs-2 ovs-int23 2  ovs-3 ovs-int32 2

# ── Red namespace ──────────────────────────────────────────────────────────────
echo "[*] Setting up namespace: red (10.0.0.100) on ovs-1 port 3"
ip netns add red
ip link add veth-red type veth peer name veth-red-br
ip link set veth-red netns red
ip netns exec red ip link set veth-red address aa:00:00:00:00:64
ip link set veth-red-br up
ip netns exec red ip link set lo up
ip netns exec red ip link set veth-red up
ip netns exec red ip addr add 10.0.0.100/24 dev veth-red
ovs-vsctl add-port ovs-1 veth-red-br -- set Interface veth-red-br ofport_request=3

# ── Green namespace ────────────────────────────────────────────────────────────
echo "[*] Setting up namespace: green (10.0.0.113) on ovs-3 port 3"
ip netns add green
ip link add veth-green type veth peer name veth-green-br
ip link set veth-green netns green
ip netns exec green ip link set veth-green address aa:00:00:00:00:71
ip link set veth-green-br up
ip netns exec green ip link set lo up
ip netns exec green ip link set veth-green up
ip netns exec green ip addr add 10.0.0.113/24 dev veth-green
ovs-vsctl add-port ovs-3 veth-green-br -- set Interface veth-green-br ofport_request=3

# ── Blue namespace (SFF) ───────────────────────────────────────────────────────
# Blue acts as a Service Function Forwarder: it has two interfaces (eth0 and
# eth1) connected by an internal Linux bridge (br0).  Frames entering on one
# interface are transparently forwarded to the other at Layer 2.
#
#   eth0 (10.0.0.111, aa:00:00:00:00:6f) → ovs-2 port 3   SFF egress
#   eth1 (10.0.0.112, aa:00:00:00:00:70) → ovs-2 port 4   SFF ingress
echo "[*] Setting up namespace: blue (SFF) on ovs-2 ports 3 and 4"
ip netns add blue

# eth0 veth pair
ip link add veth-blue0 type veth peer name veth-blue0-br
ip link set veth-blue0 netns blue
ip netns exec blue ip link set veth-blue0 address aa:00:00:00:00:6f
ip link set veth-blue0-br up

# eth1 veth pair
ip link add veth-blue1 type veth peer name veth-blue1-br
ip link set veth-blue1 netns blue
ip netns exec blue ip link set veth-blue1 address aa:00:00:00:00:70
ip link set veth-blue1-br up

# Bring up interfaces and assign IPs (needed for ONOS host discovery)
ip netns exec blue ip link set lo up
ip netns exec blue ip link set veth-blue0 up
ip netns exec blue ip link set veth-blue1 up
ip netns exec blue ip addr add 10.0.0.111/24 dev veth-blue0
ip netns exec blue ip addr add 10.0.0.112/24 dev veth-blue1

# NOTE: br0 creation and enslaving is deferred until AFTER host discovery.
# If veth-blue0/veth-blue1 are enslaved to br0 first, ONOS only sees br0's MAC
# (not the individual interface MACs) and Blue's hosts won't register correctly.

# Attach to OVS
ovs-vsctl add-port ovs-2 veth-blue0-br -- set Interface veth-blue0-br ofport_request=3
ovs-vsctl add-port ovs-2 veth-blue1-br -- set Interface veth-blue1-br ofport_request=4

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "[*] Topology ready. Controller: ${ONOS_IP}:${ONOS_PORT}"
echo ""
echo "    Namespace   Interface   IP            Switch  OFport  Role"
echo "    ---------   ---------   ----------    ------  ------  ----"
echo "    red         veth-red    10.0.0.100    ovs-1   3       Source"
echo "    blue        veth-blue0  10.0.0.111    ovs-2   3       SFF egress"
echo "    blue        veth-blue1  10.0.0.112    ovs-2   4       SFF ingress"
echo "    green       veth-green  10.0.0.113    ovs-3   3       Destination"
echo ""
echo "    [Red]──ovs-1──ovs-2──[Blue:eth0(111)]──ovs-3──[Green]"
echo "                    │    [Blue:eth1(112)]"
echo "                    │         ↕ (br0 bridge inside blue)"
echo ""

# ── Wait for ONOS to connect to all bridges ────────────────────────────────────
echo "[*] Waiting for ONOS to connect to all bridges..."
for br in $BRIDGES; do
    for i in $(seq 1 30); do
        if ovs-vsctl get-controller "$br" 2>/dev/null | grep -q tcp && \
           ovs-vsctl show 2>/dev/null | grep -A2 "Bridge $br" | grep -q "is_connected: true"; then
            echo "    $br: connected"
            break
        fi
        if [[ $i -eq 30 ]]; then
            echo "    WARNING: $br did not connect to ONOS within 30 s — host discovery may fail."
        fi
        sleep 1
    done
done

# ── Trigger host discovery ─────────────────────────────────────────────────────
_send_arps() {
    ip netns exec red   ping -c 1 -W 1 10.0.0.254 &>/dev/null &
    ip netns exec green ping -c 1 -W 1 10.0.0.254 &>/dev/null &
    # Blue's interfaces are NOT yet enslaved to br0, so each sends its own ARP
    # with its fixed MAC — ONOS registers two separate hosts (111 and 112).
    ip netns exec blue  ping -c 1 -W 1 -I veth-blue0 10.0.0.254 &>/dev/null &
    ip netns exec blue  ping -c 1 -W 1 -I veth-blue1 10.0.0.254 &>/dev/null &
    wait
}

_count_hosts() {
    curl -sf -u onos:rocks "http://${ONOS_IP}:8181/onos/v1/hosts" 2>/dev/null | \
        python3 -c "import sys,json; print(len(json.load(sys.stdin).get('hosts',[])))" 2>/dev/null || echo 0
}

echo ""
echo "[*] Triggering host discovery (pings will fail — that is expected)..."

EXPECTED=4   # Red, Green, Blue:eth0, Blue:eth1
for attempt in 1 2 3 4 5; do
    _send_arps
    sleep 2
    FOUND=$(_count_hosts)
    echo "    Attempt $attempt: $FOUND / $EXPECTED hosts registered in ONOS"
    if [[ "$FOUND" -ge "$EXPECTED" ]]; then
        break
    fi
done

if [[ "$FOUND" -ge "$EXPECTED" ]]; then
    echo ""
    echo "[*] Hosts discovered. Pushing name labels to ONOS GUI..."
    curl -sf -u onos:rocks -X POST \
        -H "Content-Type: application/json" \
        "http://${ONOS_IP}:8181/onos/v1/network/configuration" \
        -d '{
          "hosts": {
            "aa:00:00:00:00:64/-1": {"basic": {"name": "Red"}},
            "aa:00:00:00:00:6f/-1": {"basic": {"name": "Blue-eth0"}},
            "aa:00:00:00:00:70/-1": {"basic": {"name": "Blue-eth1"}},
            "aa:00:00:00:00:71/-1": {"basic": {"name": "Green"}}
          }
        }' && echo "    Labels applied." || echo "    WARNING: Could not push labels."
    echo ""
    echo "[*] Ready for intents."
else
    echo ""
    echo "    WARNING: Only $FOUND / $EXPECTED hosts found after 5 attempts."
    echo "    Re-trigger manually:"
    echo "      sudo ip netns exec red   ping -c 1 -W 1 10.0.0.254"
    echo "      sudo ip netns exec green ping -c 1 -W 1 10.0.0.254"
    echo "      sudo ip netns exec blue  ping -c 1 -W 1 -I veth-blue0 10.0.0.254"
    echo "      sudo ip netns exec blue  ping -c 1 -W 1 -I veth-blue1 10.0.0.254"
fi

# ── Create Blue SFF bridge (deferred until after host discovery) ────────────────
# Now that ONOS has seen both Blue MACs, enslave the interfaces to br0 to enable
# the bump-in-the-wire SFF forwarding behaviour.
echo ""
echo "[*] Creating Blue SFF bridge (br0: veth-blue0 <-> veth-blue1)..."
ip netns exec blue ip link add name br0 type bridge
ip netns exec blue ip link set br0 up
ip netns exec blue ip link set veth-blue0 master br0
ip netns exec blue ip link set veth-blue1 master br0
echo "    Blue SFF bridge ready."

echo ""
echo "    Verify: curl -s -u onos:rocks http://${ONOS_IP}:8181/onos/v1/hosts | python3 -m json.tool"
echo ""
echo "    Cleanup: sudo bash task.sh --clean"
