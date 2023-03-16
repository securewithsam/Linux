#### Configure a Static IP Address with Netplan on Ubuntu

```sh
sudo nano /etc/netplan/00-installer-config.yaml
```

```sh
# Network-Configuration
network:
    version: 2
   renderer: NetworkManager/ networkd
    ethernets:
       device:
          dhcp4/6: yes/no
          addresses: [IP_ADDRESS/NETMASK]
          gateway: GATEWAY
          nameservers:
             addresses: [NAMESERVER_1, NAMESERVER_2]

# device: Name of the interface.
# dhcp4/6: yes or no depending upon dynamic or static IP addressing
# addresses: IP address of the device in prefix notation. Do not use netmask.
# gateway: Gateway IP address to connect to an outside network
# nameservers: Address of DNS name servers

```

```sh
sudo netplan apply
```

```sh
ip -br addr
```
