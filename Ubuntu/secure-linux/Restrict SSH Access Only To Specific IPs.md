#### How To Restrict SSH Access Only To Specific IPs

```sh
nano /etc/hosts.allow
```
##### and add the following lines to allow the whitelisted IP blocks to your public SSH.
```sh
sshd: 10.83.133.77/32, 10.6.52.9/32, 10.11.100.11/28, 10.22.192.0/28
```
```sh
nano /etc/hosts.deny
```

##### and add the following lines to deny all SSH connections to your public SSH port

```sh
sshd: ALL
```

##### Note: make sure you double check the IP addresses, or you will be blocked by SSH
