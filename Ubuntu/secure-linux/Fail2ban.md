### Install Fail2ban

```sh
sudo apt install fail2ban -y
```
```sh
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```
```sh
sudo service fail2ban restart
```

#You can view this list by requesting the current status of the SSH service with:
```sh
sudo fail2ban-client status ssh
```

