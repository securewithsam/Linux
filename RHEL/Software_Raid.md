### Configure Software RAID on RHEL 

####* Make sure the machine has internet access
```sh
ping 8.8.8.8
```
####*Register with subscription manager and assign a subscription to the machine

```sh
subscription-manager register
```
####*From the Red Hat console, assign a subscription to the newly registered machine


```sh
subscription-manager refresh
```
```sh
subscription-manager list --available --all
```
####*Run the following command to install mdadm which is the utility to create software RAID
```sh
sudo yum install mdadm
```
####*Create partition on NVMe with parted:
```sh
parted
```
```sh
select /dev/nvme0n1
```
```sh
mklabel gpt
```
```sh
quit
```
####*Create partition on nvme 1 with fdisk and repeat steps for nvme 2 and 3
```sh
sudo fdisk /dev/nvme0n1
```
```sh
Command (m for help): n
Command (m for help): p
```
####*Examine using mdadm
```sh
sudo mdadm --examine /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1
```
####*Create a RAID
```sh
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 
```
###* Check status of raid
```sh
mdadm --detail /dev/md0
```
####*Create xfs file system on raid drive:
```sh
mkfs -t xfs /dev/md0
```
####*Create a mount point for RAID drive and mount it:
```sh
mkdir /mnt/raid5
mount /dev/md0 /mnt/raid5
```
####*If you want that RHEL mounts the md0 RAID device automatically when the system boots, add an entry for your device to the
```sh
nano /etc/fstab file
```
```sh
/dev/md0   /mnt/raid1 xfs  defaults   0 0
```















