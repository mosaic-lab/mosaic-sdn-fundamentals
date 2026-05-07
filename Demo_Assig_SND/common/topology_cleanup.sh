#!/usr/bin/env bash

# Made by : Fahim Muhtasim Hossain (Fahim.MuhtasimHossain@ruhr-uni-bochum.de)
# Instructions to run the code:
#    1. Go to directory where this file is.
#    2. run:sudo ./<file name> 

# Require root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root. Please use sudo:"
   echo "   sudo $0"
   exit 1
fi

echo "🧹 Cleaning up all network namespaces, OVS bridges, and veth interfaces..."

# Delete all non-default network namespaces
for ns in $(ip netns list | awk '{print $1}'); do
    echo "Deleting namespace: $ns"
    ip netns delete "$ns"
done

# Delete all OVS bridges
for br in $(ovs-vsctl list-br); do
    echo "Deleting OVS bridge: $br"
    ovs-vsctl del-br "$br"
done

# Delete all veth pairs (interfaces that are type veth)
for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    # Check if it's a veth interface
    if [[ "$(ethtool -i "$iface" 2>/dev/null | grep 'driver: veth')" != "" ]]; then
        echo "Deleting veth interface: $iface"
        ip link delete "$iface" || true
    fi
done

echo "✅ Cleanup complete."

