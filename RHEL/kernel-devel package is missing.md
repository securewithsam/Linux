

```sh
subscription-manager repos --enable=rhel-8-for-$(uname -m)-baseos-debug-rpms --enable=rhel-8-for-$(uname -m)-appstream-debug-rpms
```

```sh
yum install kernel-debuginfo-$(uname -r) kernel-debuginfo-common-$(uname -m)-$(uname -r)
```

```sh
dnf install -y kernel-devel-$(uname -r)
```
