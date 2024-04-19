
```sh
yum update -y
```
```sh
wget https://github.com/syncthing/syncthing/releases/download/v1.27.6/syncthing-linux-amd64-v1.27.6.tar.gz
```
```sh
 tar xvf syncthing-linux-amd64-v1.27.6.tar.gz
```
```sh
sudo cp syncthing-linux-amd64-*/syncthing  /usr/local/bin/
```
```sh
syncthing --version
```
```sh
nano /etc/systemd/system/syncthing@.service
```
paste below 
```sh
[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target

[Service]
User=%i
ExecStart=/usr/local/bin/syncthing -no-browser -gui-address=0.0.0.0:8384 -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

# Hardening
ProtectSystem=full
PrivateTmp=true
SystemCallArchitectures=native
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```
```sh
sudo firewall-cmd --zone=public --add-port=8384/tcp --permanent
sudo firewall-cmd --reload
```
```sh
 sudo systemctl daemon-reload
```
```sh
sudo systemctl start syncthing@$USER
sudo systemctl enable syncthing@$USER
```
```sh
sudo netstat -tuln | grep 8384
```
```sh
https://<RHEL_IP>:8384
```


