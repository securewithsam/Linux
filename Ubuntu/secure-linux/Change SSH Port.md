#### Change SSH Port

```sh
grep -i port /etc/ssh/sshd_config
```

```sh
nano /etc/ssh/sshd_config
```
```sh
systemctl restart sshd
```
```sh
netstat -tulpn | grep ssh
```
```sh
ssh -p 22000 192.168.1.100 
```
