#### Create SNMPv3

```sh
sudo yum install net-snmp
```
```sh
sudo service snmpd stop
```
```sh
sudo net-snmp-create-v3-user -ro -A ecmppinfchrn -a SHA -X myencryptionkey -x AES enercaresnmp
```
```sh
yum install net-snmp-utils -y
```
```sh
sudo service snmpd start
```
```sh
snmpwalk -u enercaresnmp -A ecmppinfchrn -a SHA -X myencryptionkey -x AES -l authPriv 127.0.0.1 -v3
```
