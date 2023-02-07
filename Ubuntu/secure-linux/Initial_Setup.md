
```sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get autoclean
```

#### Enable Automatic Security Updates
```sh
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

##### Customize automatic updates
##### To enable ONLY security updates, please change the code to look like this:
```sh
  // Automatically upgrade packages from these (origin:archive) pairs
  Unattended-Upgrade::Allowed-Origins {
      "${distro_id}:${distro_codename}-security";
  //  "${distro_id}:${distro_codename}-updates";
  //  "${distro_id}:${distro_codename}-proposed";
  //  "${distro_id}:${distro_codename}-backports";
```
