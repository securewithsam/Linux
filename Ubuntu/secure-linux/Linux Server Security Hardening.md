### Upgrade your Kernel
```sh
sudo apt-get update
sudo apt-get dist-upgrade
```

### Strict Firewall Rules
```sh
sudo apt-get install iptables
iptables -A INPUT -p tcp --dport ftp -j DROP
```
### Disable unnecessary Services
```sh
service --status-all
sudo service [SERVICE_NAME] stop
sudo systemctl stop [SERVICE_NAME]
```
### Check for Backdoors and Rootkits
```sh
sudo apt-get install rkhunter -y
sudo rkhunter --check
```
### Check Listening Ports
```sh
netstat -anp
sudo netstat -ulpnt
```

### Use IDS -SNORT
```sh
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
wget https://www.snort.org/downloads/snort/snort-2.9.12.tar.gz
tar xvzf daq-2.0.6.tar.gz
cd daq-2.0.6
./configure && make && sudo make install
tar xvzf snort-2.9.12.tar.gz
cd snort-2.9.12
./configure --enable-sourcefire && make && sudo make install
sudo snort
```
### Monitor Logs
```sh
tail -f -n 5 /var/log/syslog
sudo apt-get install -y loganalyzer
```
### To remove package
```sh
sudo apt-get remove [PACKAGE_NAME] -y
sudo apt-get clean
```
### Check your system for chrootkit infections:
```sh
apt install chkrootkit
sudo chkrootkit
```

```sh
sudo top
sudo iftop  <interface>
```
