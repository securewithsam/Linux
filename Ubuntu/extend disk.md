#### Enlarge a disk and partition in Linux

```sh
sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```
