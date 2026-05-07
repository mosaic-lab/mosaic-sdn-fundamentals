#!/usr/bin/env bash

function create_ns() {
    echo "Creating the namespace $1"
    ip netns add "$1"
}

function create_ovs_bridge() {
    echo "Creating the OVS bridge $1"
    ovs-vsctl add-br "$1"
    ovs-vsctl set bridge "$1" protocols=OpenFlow13
}

function attach_ns_to_ovs() {
    echo "Attaching the namespace $1 to the OVS $2"
    ip link add "$3" type veth peer name "$4"
    ip link set "$3" netns "$1"
    ovs-vsctl add-port "$2" "$4" -- set Interface "$4" ofport_request="$5"
    ip netns exec "$1" ip addr add "$6/24" dev "$3"
    ip netns exec "$1" ip link set dev "$3" up
    ip link set "$4" up
}

function attach_ovs_to_ovs() {
    echo "Attaching the OVS $1 to the OVS $2"
    ip link add name "$3" type veth peer name "$4"
    ip link set "$3" up
    ip link set "$4" up
    ovs-vsctl add-port "$1" "$3" -- set Interface "$3" ofport_request="$5"
    ovs-vsctl add-port "$2" "$4" -- set Interface "$4" ofport_request="$6"
}

function attach_ovs_to_sdn() {
    echo "Attaching the OVS bridge to the ONOS controller"
    ovs-vsctl set-controller "$1" tcp:$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q --filter ancestor=onosproject/onos)):6653
}


create_ns red1;  create_ns red2;  create_ns red3;  create_ns red4;  create_ns red5
create_ns blue1; create_ns blue2; create_ns blue3; create_ns blue4; create_ns blue5

create_ovs_bridge br-1
create_ovs_bridge br-2
create_ovs_bridge br-3
create_ovs_bridge br-4
create_ovs_bridge br-5

attach_ovs_to_ovs br-1 br-2  br-ovs12 br-ovs21  1 1
attach_ovs_to_ovs br-2 br-3  br-ovs23 br-ovs32  2 2
attach_ovs_to_ovs br-3 br-4  br-ovs34 br-ovs43  3 3
attach_ovs_to_ovs br-4 br-5  br-ovs45 br-ovs54  4 4

attach_ns_to_ovs red1  br-1  veth-red1  veth-red1-br  5  10.0.0.2
attach_ns_to_ovs red2  br-2  veth-red2  veth-red2-br  5  10.0.0.3
attach_ns_to_ovs red3  br-3  veth-red3  veth-red3-br  5  10.0.0.4
attach_ns_to_ovs red4  br-4  veth-red4  veth-red4-br  5  10.0.0.5
attach_ns_to_ovs red5  br-5  veth-red5  veth-red5-br  5  10.0.0.6

attach_ns_to_ovs blue1 br-1  veth-blue1 veth-blue1-br 6  10.0.0.129
attach_ns_to_ovs blue2 br-2  veth-blue2 veth-blue2-br 6  10.0.0.130
attach_ns_to_ovs blue3 br-3  veth-blue3 veth-blue3-br 6  10.0.0.131
attach_ns_to_ovs blue4 br-4  veth-blue4 veth-blue4-br 6  10.0.0.132
attach_ns_to_ovs blue5 br-5  veth-blue5 veth-blue5-br 6  10.0.0.133

attach_ovs_to_sdn br-1
attach_ovs_to_sdn br-2
attach_ovs_to_sdn br-3
attach_ovs_to_sdn br-4
attach_ovs_to_sdn br-5

echo "Waiting for ONOS to connect (5s)..."
sleep 5

echo "Triggering host discovery via ARP..."
for ns in red1 red2 red3 red4 red5 blue1 blue2 blue3 blue4 blue5; do
    ip netns exec "$ns" ping -c 1 -W 1 10.0.0.1 &>/dev/null || true
done
