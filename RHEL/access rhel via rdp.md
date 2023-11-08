
```sh
sudo yum groupinstall "Server with GUI"
```
```sh
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```
```sh
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```
```sh
sudo yum update
```
```sh
sudo subscription-manager repos --enable "codeready-builder-for-rhel-8-*-rpms"
```
```sh
sudo yum repolist
```
```sh
sudo yum install epel-release
```
```sh
sudo yum install xrdp -y
```
```sh
sudo systemctl enable xrdp
sudo systemctl start xrdp
```
```sh
sudo systemctl status xrdp
```
```sh
sudo nano /etc/xrdp/xrdp.ini
```
##### Add the line below 
```sh
exec gnome-session
```
```sh
sudo systemctl restart xrdp
```
```sh
sudo firewall-cmd --add-port=3389/tcp --permanent
sudo firewall-cmd --reload
```
### Open RDP and connect via root account 





