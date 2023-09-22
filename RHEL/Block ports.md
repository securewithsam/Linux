#### How to Block all ports and allow 80/443 & 2022

```sh
iptables -P INPUT DROP
```
```sh
iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --dport 2022 -j ACCEPT
```
