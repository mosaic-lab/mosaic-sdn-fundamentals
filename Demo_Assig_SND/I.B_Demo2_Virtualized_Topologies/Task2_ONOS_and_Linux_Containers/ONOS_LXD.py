import os
import time
import docker
from pylxd import Client


def create_ovs(ovs_name):
    print("Creating the OVS bridge {}".format(ovs_name))
    basic_cmd = 'sudo ovs-vsctl add-br {}'.format(ovs_name)
    os.system(basic_cmd)
    # Set OpenFlow protocol version to 1.3
    set_OF_protocol = 'sudo ovs-vsctl set bridge {} protocols=OpenFlow13'.format(ovs_name)
    os.system(set_OF_protocol)


def create_link_ovs(ovs_name_1, ovs_name_2, ovs_interface_1, ovs_interface_2, ovs_port):
    print("Attaching the OVS {} to the OVS {}".format(ovs_name_1, ovs_name_2))

    basic_cmd = 'sudo ip link add name {} type veth peer name {}'.format(ovs_interface_1, ovs_interface_2)
    os.system(basic_cmd)

    basic_cmd = "ip link set {} up".format(ovs_interface_1)
    os.system(basic_cmd)

    basic_cmd = "ip link set {} up".format(ovs_interface_2)
    os.system(basic_cmd)

    basic_cmd = "sudo ovs-vsctl add-port {0} {1} -- set Interface {1} ofport_request={2}" \
        .format(ovs_name_1, ovs_interface_1, ovs_port)
    os.system(basic_cmd)

    basic_cmd = "sudo ovs-vsctl add-port {0} {1} -- set Interface {1} ofport_request={2}" \
        .format(ovs_name_2, ovs_interface_2, ovs_port)
    os.system(basic_cmd)


def attach_ovs_to_sdn(ovs_name):
    print("Attaching the OVS bridge to the ONOS controller")
    client = docker.DockerClient()
    container = client.containers.get("onos")
    ip_add = container.attrs['NetworkSettings']['IPAddress']
    basic_cmd = "ovs-vsctl set-controller {} tcp:{}:6653".format(ovs_name, ip_add)
    os.system(basic_cmd)


def create_lxd_container(container_name, ovs_name, ip_address):
    print("Creating the container: {}".format(container_name))
    client = Client()
    if not client.profiles.exists(ovs_name):
        client.profiles.create(
            ovs_name,
            config={'environment.http_proxy': 'http://[fe80::1%eth0]:13128', 'user.network_mode': 'link-local'},
            devices={'eth0': {'name': 'eth0', 'nictype': 'bridged', 'parent': ovs_name, 'type': 'nic'}})
    config = {
        'name': container_name,
        'source':
            {
                'type': 'image',
                "mode": "pull",
                "server": "https://cloud-images.ubuntu.com/daily",
                "protocol": "simplestreams",
                'alias': 'bionic/amd64'
            },
        'profiles': [ovs_name],
        'devices': {
            'root': {
                'type': 'disk',
                'pool': 'default',
                'path': '/'
            }
        }
        }
    container = client.containers.create(config, wait=True)
    container.start()
    while client.containers.get(container_name).status != 'Running':
        time.sleep(1)
    time.sleep(5)
    
    # Assign IP and bring up interface
    basic_cmd = "lxc exec {} -- ip addr add {}/24 dev eth0".format(container_name, ip_address)
    os.system(basic_cmd)
    basic_cmd = "lxc exec {} -- ip link set dev eth0 up".format(container_name)
    os.system(basic_cmd)
    
    # Add to global list for pinging
    created_containers.append((container_name, ip_address))
 
    
# Ping all other containers to trigger discovery in ONOS
def ping_all_pairs():
    for i, (name1, ip1) in enumerate(created_containers):
        for j, (name2, ip2) in enumerate(created_containers):
            if i != j:
                os.system(f"lxc exec {name1} -- ping -c 1 {ip2} || true")
                


if __name__ == '__main__':
    create_ovs("ovs-3")
    create_ovs("ovs-4")
    create_link_ovs("ovs-3", "ovs-4", "int-ovs3", "int-ovs4", 1)
    attach_ovs_to_sdn("ovs-3")
    attach_ovs_to_sdn("ovs-4")
    created_containers = [] # Global list to store created containers and their IPs
    create_lxd_container("red", "ovs-3", "10.0.0.106")
    create_lxd_container("blue", "ovs-4", "10.0.0.107")
    ping_all_pairs()
