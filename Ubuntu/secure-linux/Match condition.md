#### How to allow root login from one IP address with ssh public keys only

```sh
sudo nano /etc/ssh/sshd_config
```

#### Example: Allow root login from from 192.168.2.5 with ssh-key but disallow everyone else
#### Append the following in your /etc/ssh/sshd_config:

```sh
## Block root login to every one ##
PermitRootLogin no
 
## No more password login  ##
PermitEmptyPasswords no
PasswordAuthentication no
 
## Allow root login with public ssh key for 192.168.21.4 only ##
Match Address 192.168.21.4
        PermitRootLogin yes
```

```sh
sudo sshd -T
sudo systemctl reload ssh
```
##### You can setup multiple IP address/CIDR as follows:
```sh
PermitRootLogin no
PermitEmptyPasswords no
PasswordAuthentication no
Match Address 192.168.184.8,202.54.1.1,192.168.1.0/24
        PermitRootLogin yes
```
