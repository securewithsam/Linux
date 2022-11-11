## Enable PSAD(Port Scan Attack Detection) 

```sh
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install psad
sudo iptables -A INPUT -j LOG
sudo iptables -A FORWARD -j LOG 
sudo iptables -L
```
```sh
nano /etc/psad/psad.conf
```
### Change the file as given below:
```sh
EMAIL_ADDRESSES   root@localhost; ##change it your email id to get psad alerts 

HOSTNAME          test-machine; # your host machine name 

HOME_NET          192.168.154.0/24; # Set LAN network 

EXTERNAL_NET      any; # Set Wan network 

ENABLE_SYSLOG_FILE      Y; #by default set yes

IPT_SYSLOG_FILE             /var/log/syslog; #change it from /message to /syslog

ENABLE_AUTO_IDS Y;         # disable by default
```
```sh
sudo psad --sig-update
```
```sh
/etc/init.d/psad start

/etc/init.d/psad stop

systemctl restart psad
```
