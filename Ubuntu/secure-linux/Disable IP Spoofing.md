#### To prevent IP Spoofing, edit the /etc/host.conf:

```sh
sudo vi /etc/host.conf
```
##### add or update the following lines:

```sh
order bind,hosts
nospoof on
```
