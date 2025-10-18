

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
sudo dnf install -y pfring-dkms n2disk nprobe ntopng cento
```

*(You typed `ntap` — that package doesn’t exist, probably a typo. Skip it.)*

---

### 🛠️ Notes

* If `tcp_wrappers-libs` isn’t found, use the `compat-tcp-wrappers` package from EPEL 9.
* If `zeromq` fails, sometimes the package name is `zeromq3` or `zeromq4` in EPEL. Use:

  ```bash
  sudo dnf search zeromq
  ```

  and install the latest available.

---

### 🎯 Simplified path (if you just want ntopng working)

If you don’t need **nProbe** and **n2disk** right now, just install ntopng + Redis:

```bash
sudo dnf install -y redis ntopng
```

That avoids PF_RING/n2disk/nProbe complexity until you’re ready to tune for full 10 Gbps capture.

---


