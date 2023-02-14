```sh
sudo dnf install cockpit
```
```sh
sudo systemctl enable --now cockpit.socket
```
##### https://Server IP:9090



#### Optional- Open Firewall Ports If needed.
```sh
sudo firewall-cmd --add-service=cockpit --permanent
sudo firewall-cmd --reload
```
