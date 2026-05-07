# SDN Lab Setup Guide
## Single-Machine Connectivity Test: ONOS Controller + OVS Switch

---

## Lab Environment

| Role | Machine | Control Interface IP |
|------|---------|----------------------|
| ONOS Controller PC | Docker installed, running the ONOS container | 192.168.1.1 |
| Switch PC | OVS installed, three NICs available | 192.168.1.11 |

**NIC Assignment (Switch PC):**
- `eth0` (or `eno1`, etc.) - control interface, has an IP address, connected to the control network
- `eth1` / `eth2` - data interfaces, no IP address, added to the OVS bridge

---

## Step 1 - ONOS PC: Start the ONOS Docker Container

```bash
docker run -d \
  --name onos \
  --restart unless-stopped \
  -p 6653:6653 \
  -p 8181:8181 \
  -p 8101:8101 \
  onosproject/onos:2.7-latest
```

Wait about 30 seconds for startup, then verify:
```bash
curl -u onos:rocks http://localhost:8181/onos/v1/devices
```

Open the firewall ports:
```bash
sudo ufw allow 6653/tcp
sudo ufw allow 8181/tcp
```

---

## Step 2 - ONOS PC: Activate Required Apps

```bash
# SSH into the ONOS CLI
ssh -p 8101 karaf@localhost
# Password: karaf

# Activate apps
app activate org.onosproject.openflow
app activate org.onosproject.fwd
app activate org.onosproject.lldpprovider
app activate org.onosproject.hostprovider

# Confirm they are active
apps -s -a
```

---

## Step 3 - Switch PC: Install OVS

```bash
sudo apt update && sudo apt install -y openvswitch-switch

# Check the version
ovs-vsctl --version
```

---

## Step 4 - Switch PC: Identify Interface Names

```bash
ip link show
```

Identify:
- Control interface: the one with an IP address (for example, `enp2s0`)
- Data interfaces: the other two (for example, `enp3s0` and `enp4s0`)

---

## Step 5 - Switch PC: Configure the OVS Bridge

```bash
# Create the bridge
sudo ovs-vsctl add-br br0

# Set OpenFlow 1.3
sudo ovs-vsctl set bridge br0 protocols=OpenFlow13

# Set a unique Datapath ID (different on each switch, 16-digit hexadecimal)
sudo ovs-vsctl set bridge br0 other-config:datapath-id=0000000000000001

# Connect to the ONOS controller (replace with the actual IP of your ONOS PC)
sudo ovs-vsctl set-controller br0 tcp:192.168.1.1:6653

# Enter secure mode after disconnection (do not forward unknown traffic)
sudo ovs-vsctl set-fail-mode br0 secure
```

Add the data interfaces to the bridge. You can test controller connectivity even before plugging in cables:
```bash
sudo ovs-vsctl add-port br0 enp3s0
sudo ovs-vsctl add-port br0 enp4s0
```

---

## Step 6 - Verify Connectivity

**On the Switch PC:**
```bash
sudo ovs-vsctl show
```

Expected output:
```
Bridge br0
    Controller "tcp:192.168.1.1:6653"
        is_connected: true    <- This is the key indicator; `true` means success
    Port br0
        Interface br0
            type: internal
```

For more details:
```bash
sudo ovs-ofctl -O OpenFlow13 show br0
```

**On the ONOS PC, confirm that the device has been registered:**
```bash
# REST API
curl -u onos:rocks http://localhost:8181/onos/v1/devices | python3 -m json.tool

# Or use the ONOS CLI
ssh -p 8101 karaf@localhost
devices    # You should see of:0000000000000001
```

**Web GUI:**
Open a browser and visit `http://192.168.1.1:8181/onos/ui`
Username: `onos` / Password: `rocks`

---

## Common Troubleshooting

| Symptom | Cause | Solution |
|---------|-------|----------|
| `is_connected: false` | Firewall is blocking port 6653 | Run `sudo ufw allow 6653/tcp` on the ONOS PC |
| `is_connected: false` | Docker is not bound to the external IP | Check `docker ps` and confirm the port is shown as `0.0.0.0:6653` |
| Cannot connect to the ONOS CLI | The container is still starting | Wait 30 seconds and check progress with `docker logs onos` |
| `devices` is empty | The OpenFlow app is not activated | Repeat Step 2 |
| Interface names are not `eth0` | systemd network interface naming | Use `ip link show` to find the actual names |

---

## Next Step: Scale to Multiple Switches

Repeat Steps 3-6 on each additional Switch PC. Note the following:
- **The Datapath ID must be unique**: use `0000000000000002` on the second switch, and so on
- **The control interface IP must be unique**: for example, `192.168.1.12`, `192.168.1.13`

---

## Overall Architecture (Multi-Machine)

```
Control network 192.168.1.0/24
┌────────────────────────────────────────────────┐
│                                                │
[ONOS PC :1]     [Switch PC1 :11]  [Switch PC2 :12]  [Switch PC3 :13]
Docker:ONOS       OVS br0            OVS br0           OVS br0
port 6653         eth0=ctrl          eth0=ctrl          eth0=ctrl
                  eth1,eth2=data     eth1,eth2=data     eth1,eth2=data
                       │                  │                  │
                  [RPi hosts]        [RPi hosts]        [RPi hosts]
```

---

## Port Summary

| Port | Protocol | Purpose |
|------|----------|---------|
| 6653 | TCP | OpenFlow 1.3 (OVS -> ONOS) |
| 6633 | TCP | Legacy OpenFlow (backward compatibility) |
| 8181 | TCP | ONOS REST API + Web GUI |
| 8101 | TCP | ONOS CLI (SSH/Karaf) |
