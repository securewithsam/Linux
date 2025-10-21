

### ✅ Fix: Enable missing repos + install dependencies

1. **Enable CRB (CodeReady Builder):**

```bash
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
```

2. **Install EPEL 9:**

```bash
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
```

3. **Refresh cache:**

```bash
sudo dnf clean all
sudo dnf makecache
```

4. **Install missing dependencies first:**

```bash
sudo dnf install -y dkms hiredis zeromq libsodium radcli tcp_wrappers-libs
```

5. **Then install ntop packages:**

```bash
yum clean all
yum update
sudo dnf install -y pfring-dkms n2disk nprobe ntopng cento ntap
```
