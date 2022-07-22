## How to set static ip in centos 8 

[Option 1]

```sh
nmcli con mod eth1 ipv4.method manual
```
```sh
nmcli con mod ens3 ipv4.address 192.168.10.100/24
nmcli con mod ens3 ipv4.gateway 192.168.10.1
nmcli con mod ens3 ipv4.dns "1.1.1.1 192.168.10.1"
```
```sh
nmcli con mod ens3 autoconnect yes
```
```sh
nmcli con down ens3
nmcli con up ens3
```
```sh
ifconfig ens3
nmcli device show ens3
```
