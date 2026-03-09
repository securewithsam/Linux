```sh
apt-get install software-properties-common wget
add-apt-repository universe
wget https://packages.ntop.org/apt/22.04/all/apt-ntop.deb
apt install ./apt-ntop.deb
```
```sh
apt-get clean all
apt-get update
apt-get install pfring-dkms nprobe ntopng n2disk cento ntap
```
```sh
apt-get update
apt-get upgrade
apt-get clean all
apt-get update
```
```sh
ntop-installer
```
```bash
 /etc/ntopng/ntopng.conf
```

```yml
--interface=enp176s0f0
--dns-mode=1
--local-networks="10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
--sticky-hosts=local
-F=clickhouse

```
#### Install Click House

https://clickhouse.com/docs/install#install-from-deb-packages

