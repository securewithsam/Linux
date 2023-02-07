To turn off IPv6, edit the /etc/sysctl.conf file and add these lines to the end.
```sh
nano /etc/sysctl.conf 
```
```sh
# disable ipv6 on the system
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

```sh
sudo nano /etc/default/ufw
```
```sh
IPV6=no
```
```sh
sudo ufw reload
```
