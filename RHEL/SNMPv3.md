#### Create SNMPv3

```sh
sudo yum install net-snmp
```
```sh
sudo service snmpd stop
```
```sh
sudo net-snmp-create-v3-user -ro -A ecchrnsnmpuser -a SHA -X ecchrnsnmpuser -x AES ecchrnsnmpuser
```
```sh
yum install net-snmp-utils -y
```
```sh
sudo service snmpd start
```
#### Test
```sh
snmpwalk -u ecchrnsnmpuser -A ecchrnsnmpuser -a SHA -X ecchrnsnmpuser -x AES -l authPriv 127.0.0.1 -v3
```


#### File Path
```sh
nano /etc/snmp/snmpd.conf
```
