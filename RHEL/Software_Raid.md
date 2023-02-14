### Configure Software RAID on RHEL 

####  Make sure the machine has internet access
```sh
ping 8.8.8.8
```
#### Register with subscription manager and assign a subscription to the machine

```sh
subscription-manager register
```
#### From the Red Hat console, assign a subscription to the newly registered machine


```sh
subscription-manager refresh
```
```sh
subscription-manager list --available --all
```

#### Add the machine to domain:
```sh
yum install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
realm discover enercare.corp
realm join --user=adm-sudk enercare.corp
realm list (to verify the list of domains)
cat /etc/sssd/sssd.conf (verify AD configuration)
```

#### Run the following command to install mdadm which is the utility to create software RAID
```sh
sudo yum install mdadm
```
#### Create a RAID 
##### [ In this example , we have 4 drives configured with Raid 5 , make sure to update the "devices = 4" and add accordingly ]
```sh
sudo mdadm --create /dev/md0 --level=5 --raid-devices=4 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 
```

#### Example 2: Raid with 6 drives
```sh
sudo mdadm --create /dev/md0 --level=5 --raid-devices=6 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1 /dev/nvme3n1 /dev/nvme4n1 /dev/nvme5n1 
```

#### Check status of raid
```sh
mdadm --detail /dev/md0
```
#### Scan Raid

```sh
mdadm --detail --scan >> /etc/mdadm.conf
```

### Configure Email Alerts
```sh
nano /etc/mdadm.conf 
```
### Add the line below and save 
```sh
MAILADDR firstname.lastname@enercare.ca
```

#### Install postfix
```sh
yum install postfix
```

#### Add hostname, relay details to postfix configuration file
```sh
vim /etc/postfix/main.cf
```
#### Edit myhostname=bpp-foss-01 and mydomain=foss.corp, relay=[relay10.foss.corp]:25

```sh
sudo systemctl restart postfix
systemctl status postfix
```

#### Install Mailx and send test email:
```sh
yum install mailx
```
```sh
echo "this is a test email" | mailx -r bpp-jmp-01@fossdom.com -s hello foss.dom@fossdom.com
```

