
```sh
visudo
```


#### Add the line under  

```sh
Allow root to run any commands anywhere
root    ALL=(ALL)       ALL

user1 ALL=(ALL)      ALL
```
or

```sh
sudo useradd -m -s /bin/bash user1
sudo passwd user1
sudo usermod -aG wheel user1
echo "user1 ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/user1
```
