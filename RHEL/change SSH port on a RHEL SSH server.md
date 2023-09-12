#### How to change the default port on a RHEL SSH server

```sh
sed -i 's/#Port 22/Port 2022/g' /etc/ssh/sshd_config
```
```sh
systemctl restart sshd
```
```sh
semanage port -a -t ssh_port_t -p tcp 2022
```
```sh
firewall-cmd --add-port=2022/tcp --permanent
```
```sh
firewall-cmd --reload
```
```sh
systemctl restart sshd
```
