
```sh
curl https://packages.ntop.org/centos-stable/ntop.repo > /etc/yum.repos.d/ntop.repo
```
```sh
yum install epel-release
```
```sh
rpm -ivh http://rpms.remirepo.net/enterprise/remi-release-8.rpm
```
```sh
yum install dnf-plugins-core
```
```sh
dnf config-manager --set-enabled PowerTools
```
```sh
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
```
```sh
dnf config-manager --set-enabled remi
```
```sh
yum clean all
```
```sh
yum update
```
```sh
yum install pfring-dkms n2disk nprobe ntopng cento ntap
```
#### http://IP:3000 (admin/admin )
