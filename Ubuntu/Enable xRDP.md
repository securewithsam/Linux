#### Installing  xrdp   (cannot rdp with root , so create user infra-admin with sudo access)

```sh
adduser infra-admin
usermod -a -G sudo infra-admin
chsh -s /bin/bash infra-admin
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
## or 
```bash
sudo apt update
sudo apt install -y xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp
sudo adduser infra-admin ssl-cert
echo "startxfce4" > /home/velnet_jason/.xsession
sudo apt install -y xfce4 xfce4-goodies
sudo systemctl restart xrdp
```
