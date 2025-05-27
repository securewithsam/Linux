

---


#### 1. **Create the user and set a secure password**

```bash
sudo useradd saurabh
sudo passwd saurabh
```

#### 2. **Add `saurabh` to the sudoers group**

```bash
sudo usermod -aG wheel saurabh
```

#### 3. **Prevent root password changes by `saurabh`**

Create a new sudoers rule that **allows general sudo** but explicitly **denies `passwd root`**.

```bash
sudo visudo -f /etc/sudoers.d/saurabh-restrict
```

Add the following:

```
saurabh ALL=(ALL) NOPASSWD: ALL
saurabh ALL=(ALL) !/usr/bin/passwd root
```

* `NOPASSWD: ALL` = No password prompt for sudo commands.
* `!/usr/bin/passwd root` = Deny attempts to change root password.

---

#### 4. **Disable sudo session credential re-prompt**

Set the `timestamp_timeout` to never ask again during the session.

In `/etc/sudoers.d/saurabh-restrict` or via `visudo`:

```bash
Defaults:saurabh timestamp_timeout=-1
```

> `-1` means the password is never asked again during the session.

---

#### 5. **Set a generic banner (e.g., "Welcome to the Developer Sandbox")**

Edit the `/etc/issue` and `/etc/motd` files:

```bash
echo "======================================" | sudo tee /etc/issue /etc/motd
echo "  Welcome to the Developer Sandbox VM " | sudo tee -a /etc/issue /etc/motd
echo "======================================" | sudo tee -a /etc/issue /etc/motd
```

Optional (for SSH sessions):

```bash
sudo sed -i 's|^#Banner.*|Banner /etc/issue|' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

---

### Optional Hardening Tips for Developers:

1. **Disable root SSH login**:
   In `/etc/ssh/sshd_config`:

   ```bash
   PermitRootLogin no
   ```

2. **Enable automatic security updates**:

   ```bash
   sudo dnf install -y dnf-automatic
   sudo systemctl enable --now dnf-automatic.timer
   ```

3. **Set auditing rules for root password attempts**:
   Use `auditctl` or configure `/etc/audit/rules.d/` to monitor `/usr/bin/passwd`.

---

