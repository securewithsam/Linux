#### Create SNMPv3

```sh
sudo yum install net-snmp
```
```sh
sudo service snmpd stop
```
```sh
sudo net-snmp-create-v3-user -ro -A rhelsnmpuser -a SHA -X rhelsnmpuser -x AES rhelsnmpuser
```
```sh
yum install net-snmp-utils -y
```
```sh
sudo service snmpd start
```
#### Test
```sh
snmpwalk -u rhelsnmpuser -A rhelsnmpuser -a SHA -X rhelsnmpuser -x AES -l authPriv 127.0.0.1 -v3
```


#### File Path
```sh
nano /etc/snmp/snmpd.conf
```
```sh

dnf install net-snmp
systemctl enable snmpd
systemctl start snmpd
systemctl status snmpd -l
dnf install net-snmp-utils
service snmpd restart
snmpwalk -v 2c -c public -O e 127.0.0.1


rocommunity public
syslocation MC-Cyxtera-DC
syscontact foss@gmail.com
```
