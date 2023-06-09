```sh
sudo nano /etc/fstab 
```
#### Next, add the following line to the bottom of that file:

```sh
tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0
```
```sh
sudo reboot
```
