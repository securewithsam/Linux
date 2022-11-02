## HPUX Troubleshooting

```sh
ifconfig lan0 down 
ifconfig lan0 up 
netstat -in
```


## Restart network service in HPUX:
```sh
/sbin/init.d/net stop
/sbin/init.d/net start
```

## Reboot HPUX
```sh
shutdown -r now
```
## To check Duplex Status
```sh
lanadmin -x 0
```
## To check interface status with mac-address
```sh
lanscan
```
## To Check the current services running
```sh
vi /etc/services
```
## To check Syslog config file and IP 
```sh
cat /etc/syslog.conf
vi /etc/syslog.conf
```
## To Start and Stop Syslog Service
```sh
/sbin/init.d/syslogd stop
/sbin/init.d/syslogd start
```
## To check SNMP config
```sh
vi /etc/snmpd.conf
```
### Modeify trap-dest: IP & comminity string
```sh
trap-dest: 172.16.xx.xx
get-community-name: EnCastR!ng
```









