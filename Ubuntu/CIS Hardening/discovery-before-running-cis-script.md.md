


### ***Discovery command that captures everything relevant about your system in one shot***



```yml
sudo bash -c '
echo "===== OS VERSION =====" && cat /etc/os-release
echo "===== RUNNING SERVICES =====" && systemctl list-units --type=service --state=running --no-pager
echo "===== LISTENING PORTS =====" && ss -tlnpu
echo "===== DOCKER CONTAINERS =====" && docker ps -a 2>/dev/null || echo "Docker not installed"
echo "===== DOCKER NETWORKS =====" && docker network ls 2>/dev/null || echo "N/A"
echo "===== INSTALLED PACKAGES (key ones) =====" && dpkg -l | grep -E "nginx|apache|mysql|postgres|redis|mongo|php|java|python|node|docker|snap|ufw|fail2ban|auditd|apparmor"
echo "===== MOUNTS / PARTITIONS =====" && lsblk && echo "---" && df -h && echo "---" && cat /etc/fstab
echo "===== SNAP PACKAGES =====" && snap list 2>/dev/null || echo "snapd not installed"
echo "===== UFW STATUS =====" && ufw status verbose 2>/dev/null || echo "UFW not installed"
echo "===== FIREWALL RULES =====" && iptables -L -n 2>/dev/null
echo "===== USERS WITH LOGIN SHELL =====" && grep -vE "nologin|false" /etc/passwd
echo "===== SUDOERS =====" && cat /etc/sudoers && ls /etc/sudoers.d/
echo "===== CRON JOBS =====" && crontab -l 2>/dev/null; ls /etc/cron.d/ 2>/dev/null
echo "===== PAM CONFIG =====" && cat /etc/pam.d/common-auth
echo "===== APPARMOR STATUS =====" && aa-status 2>/dev/null
echo "===== KERNEL MODULES LOADED =====" && lsmod | grep -E "overlay|squash|usb|udf|cramfs|vfat"
echo "===== SYSCTL CURRENT =====" && sysctl -a 2>/dev/null | grep -E "ip_forward|redirects|syncookies|randomize|ptrace|suid_dump|martians"
echo "===== SSH CONFIG =====" && cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
' 2>/dev/null | tee /tmp/system-discovery.txt

echo ""
echo "Output saved to /tmp/system-discovery.txt"
echo "Paste the contents here for analysis."
```


Yes! Here's a discovery command that captures everything relevant about your system in one shot:

```bash
sudo bash -c '
echo "===== OS VERSION =====" && cat /etc/os-release
echo "===== RUNNING SERVICES =====" && systemctl list-units --type=service --state=running --no-pager
echo "===== LISTENING PORTS =====" && ss -tlnpu
echo "===== DOCKER CONTAINERS =====" && docker ps -a 2>/dev/null || echo "Docker not installed"
echo "===== DOCKER NETWORKS =====" && docker network ls 2>/dev/null || echo "N/A"
echo "===== INSTALLED PACKAGES (key ones) =====" && dpkg -l | grep -E "nginx|apache|mysql|postgres|redis|mongo|php|java|python|node|docker|snap|ufw|fail2ban|auditd|apparmor"
echo "===== MOUNTS / PARTITIONS =====" && lsblk && echo "---" && df -h && echo "---" && cat /etc/fstab
echo "===== SNAP PACKAGES =====" && snap list 2>/dev/null || echo "snapd not installed"
echo "===== UFW STATUS =====" && ufw status verbose 2>/dev/null || echo "UFW not installed"
echo "===== FIREWALL RULES =====" && iptables -L -n 2>/dev/null
echo "===== USERS WITH LOGIN SHELL =====" && grep -vE "nologin|false" /etc/passwd
echo "===== SUDOERS =====" && cat /etc/sudoers && ls /etc/sudoers.d/
echo "===== CRON JOBS =====" && crontab -l 2>/dev/null; ls /etc/cron.d/ 2>/dev/null
echo "===== PAM CONFIG =====" && cat /etc/pam.d/common-auth
echo "===== APPARMOR STATUS =====" && aa-status 2>/dev/null
echo "===== KERNEL MODULES LOADED =====" && lsmod | grep -E "overlay|squash|usb|udf|cramfs|vfat"
echo "===== SYSCTL CURRENT =====" && sysctl -a 2>/dev/null | grep -E "ip_forward|redirects|syncookies|randomize|ptrace|suid_dump|martians"
echo "===== SSH CONFIG =====" && cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
' 2>/dev/null | tee /tmp/system-discovery.txt

echo ""
echo "Output saved to /tmp/system-discovery.txt"
echo "Paste the contents here for analysis."
```

---

### What this captures

| Section | Why it matters for CIS |
|---|---|
| Running services | Identifies what CIS might try to stop |
| Listening ports | Cross-checks against UFW rules CIS will set |
| Docker containers | Overlayfs/network bridge dependencies |
| Partitions/mounts | Whether partition checks will pass or fail |
| Snap packages | Squashfs dependency check |
| Installed apps | nginx/apache/mysql etc — web server exclusion needed |
| Users with login shell | Accounts CIS might try to lock |
| PAM config | Current auth chain before CIS modifies it |
| AppArmor | Current profile state |
| Kernel modules | What's loaded that CIS might blacklist |
| SSH config | Current state vs what CIS will apply |

---

Run it, paste the output here and I'll give you a **specific, tailored exclusion list** for your exact environment — not a generic one. That way nothing breaks and you get the best possible CIS score for your actual setup.
