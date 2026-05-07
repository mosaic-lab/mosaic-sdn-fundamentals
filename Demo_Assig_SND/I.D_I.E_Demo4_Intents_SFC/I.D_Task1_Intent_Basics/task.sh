#!/bin/bash
# task.sh - Demo 3 topology
# Creates five Linux network namespaces (Red, Black, Blue, Green, Yellow)
# connected through six OVS bridges controlled by ONOS.
#
# Topology:
#
#   [Red 10.0.0.2]──br-1──br-2────────────────╮
#                    ├────br-3──[Blue]──br-5──br-6──[Black 10.0.0.5]
#                    └────br-4──[Green]────────╯    [Yellow 10.0.0.6]
#
#   Inter-switch links:
#     br-1 ↔ br-2  (port 1 each)
#     br-1 ↔ br-3  (port 2 each)
#     br-1 ↔ br-4  (port 3 each)
#     br-2 ↔ br-6  (port 2 each)
#     br-3 ↔ br-5  (port 1 each)
#     br-4 ↔ br-6  (port 1 each)
#     br-5 ↔ br-6  (port 3 each)
#
#   Host attachments:
#     red    (10.0.0.2) → br-1 port 4
#     blue   (10.0.0.3) → br-3 port 3
#     green  (10.0.0.4) → br-4 port 2
#     black  (10.0.0.5) → br-6 port 4
#     yellow (10.0.0.6) → br-6 port 5
#
# Usage:
#   sudo bash task.sh           # start topology
#   sudo bash task.sh --clean   # remove topology

# ── ONOS controller detection ──────────────────────────────────────────────────
# If ONOS_IP is not set, detect the ONOS Docker container IP automatically.
if [[ -z "${ONOS_IP}" ]]; then
    ONOS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
        $(docker ps -q --filter ancestor=onosproject/onos) 2>/dev/null)
    if [[ -z "${ONOS_IP}" ]]; then
        echo "[!] Could not detect ONOS container IP. Falling back to 127.0.0.1"
        ONOS_IP="127.0.0.1"
    fi
fi
ONOS_PORT="${ONOS_PORT:-6653}"

BRIDGES="br-1 br-2 br-3 br-4 br-5 br-6"

# ── Cleanup ────────────────────────────────────────────────────────────────────
cleanup() {
    echo "[*] Cleaning up..."
    for br in $BRIDGES; do
        ovs-vsctl --if-exists del-br $br
    done
    for ns in red blue green black yellow; do
        ip netns del $ns 2>/dev/null
        ip link del veth-$ns-br 2>/dev/null
    done
    # Remove inter-switch veth pairs (one side each)
    for iface in br-ovs12 br-ovs13 br-ovs14 br-ovs26 br-ovs35 br-ovs46 br-ovs56; do
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

# ── Create OVS bridges ─────────────────────────────────────────────────────────
declare -A DP_IDS=(
    [br-1]="0000000000000001"
    [br-2]="0000000000000002"
    [br-3]="0000000000000003"
    [br-4]="0000000000000004"
    [br-5]="0000000000000005"
    [br-6]="0000000000000006"
)

for br in $BRIDGES; do
    echo "[*] Creating OVS bridge: $br  (DPID: ${DP_IDS[$br]})"
    ovs-vsctl add-br $br \
        -- set bridge $br other-config:datapath-id=${DP_IDS[$br]} \
        -- set bridge $br protocols=OpenFlow13 \
        -- set-controller $br tcp:${ONOS_IP}:${ONOS_PORT}
done

# ── Inter-switch links (veth pairs with explicit ofport_request) ───────────────
#
#   br-1: port1=br1↔br2, port2=br1↔br3, port3=br1↔br4, port4=red
#   br-2: port1=br2↔br1, port2=br2↔br6
#   br-3: port1=br3↔br5, port2=br3↔br1, port3=blue
#   br-4: port1=br4↔br6, port2=green,   port3=br4↔br1
#   br-5: port1=br5↔br3, port3=br5↔br6
#   br-6: port1=br6↔br4, port2=br6↔br2, port3=br6↔br5, port4=black, port5=yellow

_add_link() {
    local br_a=$1 iface_a=$2 port_a=$3 br_b=$4 iface_b=$5 port_b=$6
    echo "[*] Creating inter-switch link: $br_a:$port_a ($iface_a) <--> $br_b:$port_b ($iface_b)"
    ip link add $iface_a type veth peer name $iface_b
    ip link set $iface_a up
    ip link set $iface_b up
    ovs-vsctl add-port $br_a $iface_a -- set Interface $iface_a ofport_request=$port_a
    ovs-vsctl add-port $br_b $iface_b -- set Interface $iface_b ofport_request=$port_b
}

_add_link br-1 br-ovs12 1  br-2 br-ovs21 1
_add_link br-1 br-ovs13 2  br-3 br-ovs31 2
_add_link br-1 br-ovs14 3  br-4 br-ovs41 3
_add_link br-2 br-ovs26 2  br-6 br-ovs62 2
_add_link br-3 br-ovs35 1  br-5 br-ovs53 1
_add_link br-4 br-ovs46 1  br-6 br-ovs64 1
_add_link br-5 br-ovs56 3  br-6 br-ovs65 3

# ── Create host namespaces and attach to OVS ───────────────────────────────────
# Fixed MACs ensure consistent host IDs in ONOS across runs.
declare -A NS_IP=(   [red]="10.0.0.2"   [blue]="10.0.0.3"  [green]="10.0.0.4"
                     [black]="10.0.0.5"  [yellow]="10.0.0.6" )
declare -A NS_BR=(   [red]="br-1"       [blue]="br-3"       [green]="br-4"
                     [black]="br-6"      [yellow]="br-6" )
declare -A NS_PORT=( [red]="4"          [blue]="3"          [green]="2"
                     [black]="4"         [yellow]="5" )
declare -A NS_MAC=(  [red]="aa:00:00:00:00:02"   [blue]="aa:00:00:00:00:03"
                     [green]="aa:00:00:00:00:04"  [black]="aa:00:00:00:00:05"
                     [yellow]="aa:00:00:00:00:06" )

for ns in red blue green black yellow; do
    echo "[*] Setting up namespace: $ns (${NS_IP[$ns]}) on ${NS_BR[$ns]} port ${NS_PORT[$ns]}"
    ip netns add $ns

    ip link add veth-$ns type veth peer name veth-$ns-br
    ip link set veth-$ns netns $ns

    # Assign fixed MAC so ONOS host ID is stable across runs
    ip netns exec $ns ip link set veth-$ns address ${NS_MAC[$ns]}

    ip link set veth-$ns-br up
    ip netns exec $ns ip link set lo up
    ip netns exec $ns ip link set veth-$ns up
    ip netns exec $ns ip addr add ${NS_IP[$ns]}/24 dev veth-$ns

    ovs-vsctl add-port ${NS_BR[$ns]} veth-$ns-br -- set Interface veth-$ns-br ofport_request=${NS_PORT[$ns]}
done

echo ""
echo "[*] Topology ready. Controller: ${ONOS_IP}:${ONOS_PORT}"
echo ""
echo "    Namespace  IP          Switch  OFport"
echo "    ---------  ----------  ------  ------"
echo "    red        10.0.0.2    br-1    4"
echo "    blue       10.0.0.3    br-3    3"
echo "    green      10.0.0.4    br-4    2"
echo "    black      10.0.0.5    br-6    4"
echo "    yellow     10.0.0.6    br-6    5"
echo ""
echo "    [Red]──br-1──br-2────────────────╮"
echo "           ├────br-3──[Blue]──br-5──br-6──[Black]"
echo "           └────br-4──[Green]────────╯    [Yellow]"
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
# ONOS discovers a host only when it generates an ARP (PacketIn to hostprovider).
# Pings will FAIL (no forwarding rules yet) but the outgoing ARP is enough.
# We retry up to 5 rounds until all 5 hosts are confirmed in ONOS.

_send_arps() {
    for ns in red blue green black yellow; do
        ip netns exec $ns ping -c 1 -W 1 10.0.0.254 &>/dev/null &
    done
    wait
}

_count_hosts() {
    curl -sf -u onos:rocks "http://${ONOS_IP}:8181/onos/v1/hosts" 2>/dev/null | \
        python3 -c "import sys,json; print(len(json.load(sys.stdin).get('hosts',[])))" 2>/dev/null || echo 0
}

echo ""
echo "[*] Triggering host discovery (pings will fail — that is expected)..."

EXPECTED=5
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
    echo "[*] All $EXPECTED hosts discovered. Pushing name labels to ONOS GUI..."
    curl -sf -u onos:rocks -X POST \
        -H "Content-Type: application/json" \
        "http://${ONOS_IP}:8181/onos/v1/network/configuration" \
        -d '{
          "hosts": {
            "aa:00:00:00:00:02/-1": {"basic": {"name": "Red"}},
            "aa:00:00:00:00:03/-1": {"basic": {"name": "Blue"}},
            "aa:00:00:00:00:04/-1": {"basic": {"name": "Green"}},
            "aa:00:00:00:00:05/-1": {"basic": {"name": "Black"}},
            "aa:00:00:00:00:06/-1": {"basic": {"name": "Yellow"}}
          }
        }' && echo "    Labels applied. Hosts will show names in ONOS GUI." \
             || echo "    WARNING: Could not push labels to ONOS."
    echo ""
    echo "[*] Ready for intents."
else
    echo ""
    echo "    WARNING: Only $FOUND / $EXPECTED hosts found after 5 attempts."
    echo "    Check that pretask.py has been run and all bridges show is_connected: true."
    echo "    You can re-run discovery manually:"
    for ns in red blue green black yellow; do
        echo "      sudo ip netns exec $ns ping -c 1 -W 1 10.0.0.254"
    done
fi

echo ""
echo "    Verify: curl -s -u onos:rocks http://${ONOS_IP}:8181/onos/v1/hosts | python3 -m json.tool"
echo ""
echo "Cleanup: sudo bash task.sh --clean"
