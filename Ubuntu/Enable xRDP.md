#### Installing  xrdp   (cannot rdp with root , so create user sws with sudo access)

```sh
adduser sws
usermod -a -G sudo sws
chsh -s /bin/bash sws
cat /etc/passwd
cat /etc/group
```


# Install XRDP:
```sh
apt-get install xrdp -y
service xrdp start
service xrdp-sesman start
update-rc.d xrdp enable  
```
