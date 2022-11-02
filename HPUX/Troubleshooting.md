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
