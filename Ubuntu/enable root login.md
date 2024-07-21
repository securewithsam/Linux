

#### Enable SSH root login on Ubuntu 



```sh
nano /etc/ssh/sshd_config
```
```sh
FROM:
#PermitRootLogin prohibit-password
TO:
PermitRootLogin yes
```
```sh
sudo systemctl restart ssh
```
