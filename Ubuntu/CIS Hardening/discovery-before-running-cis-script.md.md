#### Configure and apply hardening rules in minutes with Ubuntu CIS Benchmark tooling


### ***This needs - Ubuntu Advantage subscription $25 USD Per Annum for 1 machine***



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
