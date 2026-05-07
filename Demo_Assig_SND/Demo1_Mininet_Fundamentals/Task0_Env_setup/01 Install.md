# Demo Preparation Guide — Demo1 Mininet Fundamentals

## Tested Environment

| Item | Version |
|------|---------|
| OS | Ubuntu 20.04.6 LTS |
| Python | Python 3.8.10 |

This Task0 covers the basic installation, first startup, verification, and cleanup steps required before running the Demo1 Mininet exercises. The stack uses **Open vSwitch (OVS)** as the virtual switch, **ONOS** as the SDN controller (running in Docker), and **Mininet** to emulate the network.

## What This Task0 Covers

- Installing the required runtime components: Docker, OVS, and Mininet
- Starting ONOS and activating the minimum required applications
- Verifying that the controller, switch runtime, and Mininet CLI are working
- Cleaning the environment before repeating a demo run

## Environment Assumptions

- Ubuntu-based Linux environment
- `sudo` access available
- Internet access available for package/image download
- The lab is run from the `Demo_SND` repository, where shared cleanup scripts are under `common/`

## Fast Path — Minimum Startup Sequence

If you already have the software installed, the shortest path to a working lab is:

1. Start Docker and confirm it is running.
2. Start ONOS with the provided `docker run` command.
3. Activate the required ONOS applications from the Karaf CLI.
4. Verify the ONOS Web UI opens at `http://localhost:8181/onos/ui`.
5. Run a small Mininet topology and confirm basic connectivity.
6. Use the cleanup script before the next run.

---

## Step 1 — Install and Configure Docker

Docker is used to run the ONOS controller in an isolated container, avoiding complex native installation.

```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Allow running Docker without sudo (log out and back in after this)
sudo usermod -aG docker $USER
newgrp docker
```

> **Why:** ONOS has many Java dependencies. Running it in Docker keeps the host clean and makes it easy to reset between demos.

---

## Step 2 — Install Open vSwitch (OVS)

OVS is the software switch that Mininet uses. It speaks OpenFlow to the ONOS controller.

```bash
sudo apt install openvswitch-switch -y
sudo systemctl start ovs-vswitchd

# Verify installation
ovs-vsctl --version
```

> **Why:** Mininet creates virtual switches using OVS. Without it, no topology can be emulated.

---

## Step 3 — Install Mininet

Mininet creates virtual networks using Linux network namespaces and OVS. It is the main tool used to emulate SDN topologies in this session.

### Option A — Install Mininet with Python 2.7 bindings

```bash
sudo apt install mininet -y
```

### Option B — Install Mininet with Python 3 bindings via Git source

```bash
git clone https://github.com/mininet/mininet.git
cd mininet
sudo PYTHON=python3 util/install.sh -n
```

Verify before moving on:

```bash
# Confirm the mn CLI is available
mn --version

# Confirm the Python 3 module is importable
sudo python3 -c "from mininet.net import Mininet; print('Mininet Python3 OK')"
```

> **Recommendation:** Use the Git-based Python 3 installation if you plan to run Mininet Python scripts directly.

---

## Step 4 — Pull the ONOS Docker Image

Download the official ONOS image from Docker Hub. This only needs to be done once (or when you want a newer version).

```bash
docker pull onosproject/onos
```

---

## Step 5 — Run the ONOS Controller

Start ONOS as a background container, exposing the three key ports:

| Port | Purpose |
|------|---------|
| `8181` | REST API and Web UI (HTTP) |
| `8101` | SSH CLI (Karaf shell) |
| `6653` | OpenFlow channel (switches connect here) |

```bash
docker run -d --name onos \
  -p 8181:8181 \
  -p 8101:8101 \
  -p 6653:6653 \
  onosproject/onos
```

Verify the container is running:

```bash
docker ps | grep onos
```

### To restart a stopped container

```bash
docker stop onos && docker rm onos
# Then re-run the docker run command above
```

If the container starts but ONOS is still booting, wait 20-60 seconds before trying the UI or Karaf SSH.

---

## Step 6 — Activate ONOS Applications

Once ONOS is running, connect to its Karaf CLI and enable the required apps.

```bash
ssh -p 8101 karaf@localhost
# Password: karaf
```

Inside the Karaf shell:

```
app activate org.onosproject.openflow       # OpenFlow southbound protocol
app activate org.onosproject.lldpprovider   # Discovers links between switches
app activate org.onosproject.hostprovider   # Discovers hosts attached to switches
app activate org.onosproject.fwd            # Reactive forwarding (basic L2 learning)
```

> **Why these apps:**
> - `openflow` — lets ONOS speak to OVS switches via the OpenFlow protocol.
> - `lldpprovider` — sends LLDP probes to auto-discover the network topology.
> - `hostprovider` — learns host locations from ARP/NDP traffic.
> - `fwd` — installs flow rules reactively so traffic can flow end-to-end without manual configuration.

---

## Step 7 — Access the ONOS Web UI

Open a browser and navigate to:

```
http://localhost:8181/onos/ui
```

| Field    | Value  |
|----------|--------|
| Username | `onos` |
| Password | `rocks` |

### Topology View — Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `H` | Toggle host visibility |
| `L` | Cycle device labels (ID → friendly name → none) |
| `I` | Toggle the ONOS instances panel (cluster nodes) |
| `D` | Toggle the details panel (selected device/link/host info) |
| `P` | Toggle port labels on links |
| `B` | Toggle background geo map |
| `A` | Zoom to fit all devices in view |
| `R` | Reset zoom and pan to default |
| `F` | Focus/zoom into the selected element |
| `E` | Toggle link stats / utilization overlay |
| `Esc` | Deselect / close side panels |
| `/` | Show the full keyboard shortcuts help dialog |

### Mouse Interactions

- **Click** a switch or host — opens the details panel for that element
- **Click** a link — shows link details (ports, state, utilization)
- **Ctrl + click** — multi-select devices or links
- **Drag** on empty space — pan the canvas
- **Scroll wheel** — zoom in / out

### General Tips

- If the topology looks empty after connecting Mininet, wait a few seconds for LLDP discovery to finish, then press **`A`** to fit the view.
- Hosts only appear after they generate traffic (e.g., a `ping`). Press **`H`** after running your first ping to reveal them.
- Use **`L`** to switch to friendly names when demoing — device IDs (`of:0000…`) are hard to read for an audience.
- The details panel shows installed **flow rules** when you click a switch — useful for demonstrating how `fwd` installs rules reactively.

### Quick controller-side verification

Use these commands to confirm that ONOS is reachable before starting a larger topology:

```bash
curl -u onos:rocks http://localhost:8181/onos/v1/devices
curl -u onos:rocks http://localhost:8181/onos/v1/hosts
curl -u onos:rocks http://localhost:8181/onos/v1/applications
```

---

## Step 8 — Cleanup Between Demos

### Recommended: full reset (topology + ONOS state)

```bash
cd ../../common
sudo ./clean_all.sh
```

### Optional: clean up only network topology (OVS bridges, ports, namespaces)

```bash
cd ../../common
sudo ./topology_cleanup.sh
```

### Optional: clean up only ONOS state (devices, links, hosts in the UI)

```bash
cd ../../common
./onos_cleanup.sh
```

Run one of these cleanup options before each fresh demo run to avoid stale state confusing the topology view.

If you are already in the repository root `Demo_SND/`, the equivalent commands are:

```bash
sudo ./common/clean_all.sh
sudo ./common/topology_cleanup.sh
./common/onos_cleanup.sh
```

---

## Optional — LXC/Docker Python Bindings (for Demo2+)

This section is **not required for Demo1**. It is only needed for later demos that use namespaces, LXC/LXD, or Docker-based topology scripts.

```bash
# LXC Python bindings
sudo apt-get install python3-lxc
pip install pylxd

# Docker Python SDK
pip install docker pylxd

# Initialize LXD (snap-based)
sudo snap install lxd
sudo lxd init --auto
sudo lxd waitready
```

> **Why:** Some advanced topology scripts use LXC containers as hosts instead of Mininet's lightweight namespaces. This gives each host a more realistic OS environment.

---

## Quick Reference — Startup Checklist

- [ ] Docker service is running (`systemctl status docker`)
- [ ] OVS is running (`systemctl status ovs-vswitchd`)
- [ ] Mininet is installed (`mn --version`)
- [ ] ONOS container is up (`docker ps | grep onos`)
- [ ] ONOS apps activated via Karaf SSH
- [ ] Web UI accessible at `http://localhost:8181/onos/ui`
- [ ] Previous topology cleaned up (`clean_all.sh` recommended)

---

## Official References

These links point students to the official documentation most relevant for this demo.

### Docker

- Install Docker Engine on Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- Linux post-install steps: https://docs.docker.com/engine/install/linux-postinstall/

### Mininet

- Get started / install options: https://mininet.org/download/
- Walkthrough: https://mininet.org/walkthrough
- Documentation and wiki: https://mininet.org/docs
- Python API introduction: https://github.com/mininet/mininet/wiki/Introduction-to-Mininet

### Open vSwitch

- Installation guide: https://docs.openvswitch.org/en/latest/intro/install/
- Linux installation details: https://docs.openvswitch.org/en/latest/intro/install/general/
- Command reference: https://docs.openvswitch.org/en/latest/ref/

### ONOS

- ONOS project documentation portal: https://docs.onosproject.org/
- Deploy ONOS classic: https://docs.onosproject.org/onos-docs/docs/content/developers/deploy_onos_classic/
- ONOS REST API reference: https://wiki.onosproject.org/display/ONOS/Appendix+B%3A+REST+API

## Useful ONOS REST API Entry Points

For this demo, students usually only need a small subset of the ONOS northbound API. All endpoints below use the same base URL:

```text
http://localhost:8181/onos/v1
```

Common endpoints:

- `GET /devices` — list switches/devices known to ONOS
- `GET /links` — list discovered links between switches
- `GET /hosts` — list discovered end hosts
- `GET /flows` — inspect installed flow rules
- `GET /applications` — inspect active/inactive ONOS apps
- `GET /intents` — inspect high-level intents used in later demos

Example queries:

```bash
curl -u onos:rocks http://localhost:8181/onos/v1/devices
curl -u onos:rocks http://localhost:8181/onos/v1/links
curl -u onos:rocks http://localhost:8181/onos/v1/flows
```

These endpoints are enough for students to check whether switches registered correctly, whether LLDP discovered links, and whether ONOS has installed forwarding rules.
