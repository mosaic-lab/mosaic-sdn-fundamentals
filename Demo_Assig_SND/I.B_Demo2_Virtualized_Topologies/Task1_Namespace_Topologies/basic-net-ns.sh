#!/usr/bin/env bash

# Instructions to run the topo:
#    1. Go to directory where this file is.
#    2. run:sudo ./<file name>

# Function to create a network namespace
function create_ns() {
  echo "Creating the namespace $1"
  ip netns add $1  # Create a network namespace named $1
}

# Function to create an OVS bridge
function create_ovs_bridge() {
  echo "Creating the OVS bridge $1"
  ovs-vsctl add-br $1  # Add an Open vSwitch (OVS) bridge with name $1
  ovs-vsctl set bridge $1 protocols=OpenFlow13 # Set OpenFlow protocol in each OVS
}

# Function to connect a network namespace to an OVS bridge
function attach_ns_to_ovs() {
  echo "Attaching the namespace $1 to the OVS $2"
  
  # Create a virtual Ethernet (veth) pair. One end is $3, the other is $4.
  ip link add $3 type veth peer name $4
  
  # Move one end ($3) into the namespace $1
  ip link set $3 netns $1
  
  # Attach the other end ($4) to the OVS bridge $2 with a specific OpenFlow port number $5
  ovs-vsctl add-port $2 $4 -- set Interface $4 ofport_request=$5
  
  # Assign IP address $6 to the interface $3 inside the namespace
  ip netns exec $1 ip addr add $6/24 dev $3
  
  # Bring up the interface inside the namespace
  ip netns exec $1 ip link set dev $3 up
  
  # Bring up the interface on the OVS side
  ip link set $4 up
}

# Function to connect two OVS bridges using a veth pair
function attach_ovs_to_ovs() {
  echo "Attaching the OVS $1 to the OVS $2"
  
  # Create a veth pair named $3 and $4
  ip link add name $3 type veth peer name $4
  
  # Bring both interfaces up
  ip link set $3 up
  ip link set $4 up
  
  # Connect one end ($3) to bridge $1
  ovs-vsctl add-port $1 $3 -- set Interface $3 ofport_request=$5
  
  # Connect the other end ($4) to bridge $2
  ovs-vsctl add-port $2 $4 -- set Interface $4 ofport_request=$5
}

# Function to set the ONOS SDN controller as the controller for an OVS bridge
function attach_ovs_to_sdn() {
  echo "Attaching the OVS bridge to the ONOS controller"
  
  # Get the IP address of the running ONOS Docker container and set it as the controller
  ovs-vsctl set-controller $1 tcp:$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q  --filter ancestor=onosproject/onos)):6653
  ## Chage it to the ONOS runnning on local machine
  # ovs-vsctl set-controller $1 tcp:127.0.0.1:6653

}

# --- Script Execution Begins Here ---

# Create two network namespaces called "red" and "blue"
create_ns red
create_ns blue

# Create two OVS bridges named br-1 and br-2
create_ovs_bridge br-1
create_ovs_bridge br-2

# Connect the two OVS bridges to each other using a veth pair
# br-1 is connected to br-2 via interfaces br-ovs1 and br-ovs2, with port number 1
attach_ovs_to_ovs br-1 br-2 br-ovs1 br-ovs2 1

# Connect namespace "red" to bridge br-1
# veth-red is inside the namespace, veth-red-br is connected to br-1, using port 2
# Assign IP 10.0.0.2 to the red namespace interface
attach_ns_to_ovs red br-1 veth-red veth-red-br 2 10.0.0.2

# Connect namespace "blue" to bridge br-2
# veth-blue is inside the namespace, veth-blue-br is connected to br-2, using port 2
# Assign IP 10.0.0.3 to the blue namespace interface
attach_ns_to_ovs blue br-2 veth-blue veth-blue-br 2 10.0.0.3

# Attach both OVS bridges to the ONOS controller
attach_ovs_to_sdn br-1
attach_ovs_to_sdn br-2

# Test connectivity: From red namespace, ping blue
ip netns exec red ping -c 1 10.0.0.3

# Test connectivity: From blue namespace, ping red
ip netns exec blue ping -c 1 10.0.0.2

