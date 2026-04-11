# CIS Ubuntu 24.04 LTS Hardening Kit

> **Enterprise-ready CIS Build Kit v1.0.0 — plug and play, no lockouts, production safe.**

This repository contains the official CIS Build Kit for Ubuntu 24.04 LTS, pre-configured with a safe exclusion list and companion pre-hardening script. Designed for enterprise production servers running web applications.

---

## What's Inside the TAR

```
cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0.tar
  └── cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/
        └── cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/
              ├── cis-pre-harden.sh          ← run this FIRST
              ├── exclusion_list.txt         ← safe exclusion list (replaces original)
              ├── ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh   ← official CIS kit
              ├── functions/                 ← CIS check scripts (do not modify)
              ├── logs/                      ← output logs go here
              ├── Changelog.txt
              ├── README.txt
              └── return_codes.txt
```

---

## Why This Exists

The official CIS Build Kit applied without customisation **breaks production systems**:
- Locks out all users including console access
- Removes web servers (nginx/apache)
- Corrupts PAM authentication chain
- Locks bootloader breaking VM recovery

This kit solves that by including a **safe exclusion list** that skips dangerous controls and a **pre-hardening script** that configures the system correctly before the kit runs — giving you a high CIS score without breaking anything.

---

## Requirements

- Ubuntu 24.04 LTS (vanilla or existing install)
- Root / sudo access
- SSH access on port 22
- Internet access for package installation during pre-harden

---

## How to Use

### Step 1 — Upload the TAR to Your Server

```bash
scp cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0.tar azureuser@<server-ip>:~/CIS/
```

Or use WinSCP to drag and drop to `~/CIS/` on the server.

---

### Step 2 — Connect and Extract

```bash
ssh azureuser@<server-ip>

mkdir -p ~/CIS && cd ~/CIS

tar -xf cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0.tar
```

Navigate into the kit folder:

```bash
cd cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0
```

Verify the contents:

```bash
ls -la
```

You should see `cis-pre-harden.sh`, `exclusion_list.txt`, and `ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh`.

---

### Step 3 — Set Permissions

```bash
chmod +x cis-pre-harden.sh
chmod +x ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh
```

---

### Step 4 — (Optional) Baseline CIS Score Before Hardening

Capture your score before so you can compare after:

```bash
sudo apt install -y libopenscap8 ssg-debderived

sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
  --report /tmp/cis-report-BEFORE.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2404-ds.xml
```

---

### Step 5 — Run the Pre-Hardening Script

> ⚠️ Run this **BEFORE** the CIS kit. It pre-configures UFW, auditd, AppArmor, chrony, rsyslog, AIDE, sysctl, and SSH so the kit finds everything already correct and scores more passes.

```bash
sudo bash cis-pre-harden.sh
```

Type `yes` when prompted and let it complete. Takes approximately 5–10 minutes.

> ⚠️ After it finishes, **open a new terminal and verify SSH still works** before continuing.

---

### Step 6 — Run the Official CIS Build Kit

```bash
sudo bash ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh
```

When prompted:

```
Do you want to continue? y/n [n]: y

Please enter the number for the desired profile:
        1: L1S - Level 1 Server        ← SELECT THIS
        2: L1W - Level 1 Workstation
        3: L2S - Level 2 Server
        4: L2W - Level 2 Workstation

Profile: 1
```

The kit will run through all controls. Controls in the exclusion list are skipped automatically. Takes approximately 5–15 minutes.

---

### Step 7 — Final CIS Score After Hardening

```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
  --report /tmp/cis-report-AFTER.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2404-ds.xml
```

Copy the reports to your Windows machine:

```bash
# From PowerShell on your Windows machine
scp azureuser@<server-ip>:/tmp/cis-report-BEFORE.html C:\Users\YourName\Desktop\
scp azureuser@<server-ip>:/tmp/cis-report-AFTER.html C:\Users\YourName\Desktop\
```

---

### Step 8 — Save Logs and Reboot

```bash
# Save CIS kit logs before deleting (useful for compliance evidence)
cp -r ~/CIS/cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/logs ~/cis-logs-backup
```

> ⚠️ **Test SSH login in a NEW terminal before rebooting.**

```bash
sudo reboot
```

After reboot, verify services are running:

```bash
systemctl status ssh
systemctl status ufw
systemctl status fail2ban
systemctl status auditd
ufw status verbose
```

---

### Step 9 — Clean Up (Optional)

Once confirmed everything works:

```bash
rm -rf ~/CIS
```

The hardening is written to system files and persists after the folder is deleted.

---

## What the Exclusion List Skips

| Controls | Reason |
|---|---|
| `1.1.2.x` — Partition checks | Vanilla installs use single partition — these fail and may cause dangerous remounts |
| `1.1.1.6-7` — overlayfs / squashfs | Required by Docker, snap, and LXC containers |
| `1.4.1-2` — Bootloader password | Breaks VM recovery mode |
| `1.7.x` — GDM desktop checks | Servers have no desktop environment |
| `2.1.18` — Web server removal | Production web apps must keep running |
| `4.3.x / 4.4.x` — nftables / iptables | Using UFW — only one firewall tool allowed |
| `5.3.2.2-4` — PAM faillock/pwquality | Aggressive PAM changes cause system lockouts |
| `5.3.3.x` — Password complexity | Corrupts PAM auth chain on vanilla installs |
| `5.4.1.x` — Password expiry | Locks users out at next login |
| `5.4.2.8` — Lock no-shell accounts | Breaks service accounts used by web apps |
| `6.1.2.1.x` — Remote journal | Requires remote logging server |
| `6.1.3.6` — Remote syslog | Requires remote syslog server |
| `6.2.2.3` — Shutdown on full logs | Shuts down server if audit log fills — extremely dangerous |

---

## What Gets Hardened

| Area | Details |
|---|---|
| **SSH** | Port 22, root login disabled, strong ciphers, session limits |
| **UFW Firewall** | Default deny, loopback allowed, port 22 open |
| **Fail2Ban** | Bans after 4 failed SSH attempts for 15 minutes |
| **Kernel (sysctl)** | ASLR, SYN cookies, redirect blocking, martian logging |
| **auditd** | Full CIS rule set — identity, sudo, file deletion, modules |
| **AppArmor** | All profiles enforced |
| **rsyslog / journald** | Configured and persistent |
| **Chrony** | Time sync active and CIS compliant |
| **AIDE** | File integrity baseline + daily check at 05:00 |
| **Sudo** | PTY required, logging enabled, 5 min timeout |
| **Cron** | Permissions hardened, restricted to root |
| **File permissions** | passwd, shadow, group, gshadow all CIS compliant |
| **Auto-updates** | Unattended security upgrades enabled |

---

## Troubleshooting

**Cannot SSH after running scripts:**
```bash
sudo systemctl restart ssh
sudo ufw status verbose
sudo fail2ban-client status sshd
sudo fail2ban-client unban <your-ip>   # if your IP was banned
sudo sshd -t                           # check SSH config is valid
```

**CIS kit log files:**
```bash
ls ~/CIS/cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/cis_lbk_ubuntu_linux_24.04_lts_benchmark_v1.0.0/logs/
# CIS-LBK_failed.log    ← controls that failed
# CIS-LBK_skipped.log   ← controls skipped by exclusion list
# CIS-LBK_verbose.log   ← full detail log
```

**OpenSCAP content file missing:**
```bash
sudo apt install --reinstall ssg-debderived
ls /usr/share/xml/scap/ssg/content/ssg-ubuntu2404-ds.xml
```

---

## Notes

- Passwords and password policy are **not changed** by this kit
- SSH remains on **port 22**
- Web applications continue to run normally
- Docker and snap packages are not broken
- Tested on Azure Ubuntu 24.04 LTS VMs

---

## File Versions

| File | Version |
|---|---|
| CIS Build Kit | v1.0.0 — Ubuntu 24.04 LTS |
| exclusion_list.txt | Safe Edition v1.0 |
| cis-pre-harden.sh | v1.0 |
