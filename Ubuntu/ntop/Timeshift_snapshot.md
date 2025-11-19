```sh
apt install timeshift 
sudo mkdir -p /mnt/timeshift-backup
sudo mount /dev/sdc1 /mnt/timeshift-backup
df -h | grep sdc1
sudo timeshift --snapshot-device /dev/sdc1 --create --comments "Before ntop"
sudo timeshift --snapshot-device /dev/sdc1 --create --comments "Working  ntop"


Step 4: Make the disk auto-mount at boot (recommended)
sudo blkid /dev/sdc1
sudo nano /etc/fstab
UUID=74d8e872-7ff4-41ce-af1b-9b27dbc411b3  /mnt/timeshift-backup  ext4  defaults  0  2
sudo mount -a

sudo timeshift --list

sudo timeshift --snapshot-device /dev/sda2 --list
sudo timeshift --snapshot-device /dev/sdc1 --list
```
