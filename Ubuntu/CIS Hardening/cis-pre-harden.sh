#!/bin/bash
# =============================================================================
# CIS Ubuntu 24.04 LTS - PRE-HARDENING COMPANION SCRIPT
# Run this BEFORE the official CIS Build Kit
#
# What this does:
#  1. Drops the safe exclusion_list.txt into the CIS kit directory
#  2. Configures UFW with SSH port 22 open (CIS 4.2.x will pass)
#  3. Sets up /dev/shm properly so partition checks pass
#  4. Configures chrony for time sync (CIS 2.3.x will pass)
#  5. Ensures rsyslog is ready (CIS 6.1.3.x will pass)
#  6. Ensures auditd is ready (CIS 6.2.x will pass)
#  7. Installs fail2ban as brute-force protection (replaces PAM lockout)
#  8. Sets SSH port 22 hardened config (CIS 5.1.x will pass)
#  9. Configures AppArmor (CIS 1.3.x will pass)
# 10. Restarts SSH safely after everything
#
# Usage:
#   sudo bash cis-pre-harden.sh /path/to/CIS-LBK
#
# Then run the CIS kit:
#   sudo bash ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="/var/log/cis-pre-harden-$(date +%Y%m%d-%H%M%S).log"

log()    { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()    { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
header() { echo -e "\n${CYAN}=== $1 ===${NC}" | tee -a "$LOG_FILE"; }

if [[ $EUID -ne 0 ]]; then
  err "Run as root: sudo bash $0"
  exit 1
fi

# Find the CIS kit directory
CIS_KIT_DIR="${1:-}"
if [[ -z "$CIS_KIT_DIR" ]]; then
  # Try to auto-detect
  CIS_KIT_DIR=$(find /root /home /opt /tmp -maxdepth 4 -name "ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || true)
fi

if [[ -z "$CIS_KIT_DIR" || ! -f "$CIS_KIT_DIR/ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh" ]]; then
  warn "CIS kit not found. Pass the path as argument: sudo bash $0 /path/to/CIS-LBK/cis_lbk_ubuntu..."
  warn "Continuing without dropping exclusion_list.txt into kit directory."
  warn "You must manually copy exclusion_list.txt into the CIS kit folder before running the kit."
  CIS_KIT_DIR=""
fi

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║   CIS Ubuntu 24.04 LTS - Pre-Hardening Companion    ║"
echo "  ║   Run this BEFORE the official CIS Build Kit        ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Log: $LOG_FILE"
[[ -n "$CIS_KIT_DIR" ]] && log "CIS kit found at: $CIS_KIT_DIR"
echo ""
read -rp "Continue? (yes/no): " CONFIRM
[[ "$CONFIRM" != "yes" ]] && { echo "Aborted."; exit 0; }

# =============================================================================
header "1. Drop Safe Exclusion List into CIS Kit"
# =============================================================================
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
EXCL_SRC="$SCRIPT_DIR/exclusion_list.txt"

if [[ -n "$CIS_KIT_DIR" ]]; then
  if [[ -f "$EXCL_SRC" ]]; then
    cp "$EXCL_SRC" "$CIS_KIT_DIR/exclusion_list.txt"
    log "exclusion_list.txt copied to CIS kit at $CIS_KIT_DIR"
  else
    warn "exclusion_list.txt not found next to this script at $EXCL_SRC"
    warn "Please copy exclusion_list.txt manually to: $CIS_KIT_DIR/exclusion_list.txt"
  fi
else
  warn "Skipped - CIS kit path not found. Copy exclusion_list.txt manually."
fi

# =============================================================================
header "2. System Updates"
# =============================================================================
log "Updating system packages..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
apt-get autoremove -y -qq

# =============================================================================
header "3. Install Required Packages"
# =============================================================================
log "Installing required packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  ufw \
  fail2ban \
  auditd \
  audispd-plugins \
  rsyslog \
  chrony \
  apparmor \
  apparmor-utils \
  aide \
  aide-common \
  libpam-pwquality \
  unattended-upgrades \
  acl

log "All packages installed."

# =============================================================================
header "4. SSH Hardening (Port 22 - CIS 5.1.x)"
# =============================================================================
log "Backing up and writing CIS-compliant sshd_config..."
cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d)" 2>/dev/null || true

cat > /etc/ssh/sshd_config <<'EOF'
# CIS Ubuntu 24.04 LTS Benchmark - Hardened SSH Config
Protocol 2
Port 22

# CIS 5.1.20 - PermitRootLogin
PermitRootLogin no

# CIS 5.1.19 - PermitEmptyPasswords
PermitEmptyPasswords no

# Authentication - password based (no key required)
PasswordAuthentication yes
PubkeyAuthentication no

# CIS 5.1.22 - UsePAM
UsePAM yes

# CIS 5.1.8 - DisableForwarding
DisableForwarding yes

# CIS 5.1.9 - GSSAPIAuthentication
GSSAPIAuthentication no

# CIS 5.1.10 - HostbasedAuthentication
HostbasedAuthentication no

# CIS 5.1.11 - IgnoreRhosts
IgnoreRhosts yes

# CIS 5.1.13 - LoginGraceTime
LoginGraceTime 60

# CIS 5.1.14 - LogLevel
LogLevel VERBOSE

# CIS 5.1.16 - MaxAuthTries
MaxAuthTries 4

# CIS 5.1.17 - MaxSessions
MaxSessions 10

# CIS 5.1.18 - MaxStartups
MaxStartups 10:30:60

# CIS 5.1.21 - PermitUserEnvironment
PermitUserEnvironment no

# CIS 5.1.7 - ClientAlive
ClientAliveInterval 15
ClientAliveCountMax 3

# CIS 5.1.5 - Banner
Banner /etc/issue.net

# CIS 5.1.6 - Strong Ciphers
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# CIS 5.1.15 - Strong MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# CIS 5.1.12 - Strong KexAlgorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
EOF

chmod 600 /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config

log "Validating SSH config..."
if sshd -t; then
  log "SSH config valid."
  systemctl daemon-reload
  systemctl restart ssh
  sleep 2
  systemctl is-active ssh && log "SSH running on port 22." || err "SSH failed to start!"
else
  err "SSH config invalid — restoring backup."
  cp "/etc/ssh/sshd_config.bak.$(date +%Y%m%d)" /etc/ssh/sshd_config
  systemctl restart ssh
fi

# SSH key file permissions (CIS 5.1.2 / 5.1.3)
find /etc/ssh -name "ssh_host_*_key" -exec chmod 600 {} \; -exec chown root:root {} \;
find /etc/ssh -name "ssh_host_*_key.pub" -exec chmod 644 {} \; -exec chown root:root {} \;
log "SSH host key permissions set."

# =============================================================================
header "5. UFW Firewall (CIS 4.2.x)"
# =============================================================================
log "Configuring UFW..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw default deny forward

# Loopback (CIS 4.2.4)
ufw allow in on lo
ufw allow out on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1

# SSH port 22 (CIS 4.2.6)
ufw allow 22/tcp comment 'SSH - CIS 4.2.6'

ufw logging on
ufw --force enable

# Restart SSH after UFW enable
sleep 2
systemctl restart ssh
log "UFW enabled. SSH restarted post-UFW."
ufw status verbose | tee -a "$LOG_FILE"

# =============================================================================
header "6. Fail2Ban (Brute Force Protection - replaces PAM lockout)"
# =============================================================================
log "Configuring fail2ban..."
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime  = 900
findtime = 300
maxretry = 4
backend  = systemd
banaction = ufw

[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
backend  = systemd
maxretry = 4
bantime  = 900
findtime = 300
EOF

systemctl enable fail2ban
systemctl restart fail2ban
log "Fail2ban active — bans after 4 failures for 15 minutes."

# =============================================================================
header "7. /dev/shm Configuration (CIS 1.1.2.2.x)"
# =============================================================================
log "Configuring /dev/shm mount options..."
if ! grep -q "^tmpfs /dev/shm" /etc/fstab; then
  echo "tmpfs  /dev/shm  tmpfs  defaults,nodev,nosuid,noexec  0 0" >> /etc/fstab
  log "Added /dev/shm to fstab with nodev,nosuid,noexec"
else
  # Update existing entry
  sed -i 's|^tmpfs\s*/dev/shm\s.*|tmpfs  /dev/shm  tmpfs  defaults,nodev,nosuid,noexec  0 0|' /etc/fstab
  log "Updated /dev/shm fstab entry"
fi
mount -o remount /dev/shm 2>/dev/null && log "/dev/shm remounted." || warn "/dev/shm remount skipped (will apply on reboot)."

# =============================================================================
header "8. Chrony Time Sync (CIS 2.3.x)"
# =============================================================================
log "Configuring chrony..."
systemctl enable chrony
systemctl start chrony

# Ensure chrony runs as _chrony (CIS 2.3.3.2)
if id _chrony &>/dev/null; then
  sed -i 's/^#\?user .*/user _chrony/' /etc/chrony/chrony.conf 2>/dev/null || true
  log "Chrony user set to _chrony"
fi
systemctl restart chrony
log "Chrony time sync configured."

# =============================================================================
header "9. Audit Daemon - auditd (CIS 6.2.x)"
# =============================================================================
log "Configuring auditd..."

# CIS 6.2.2.1 - Storage size
sed -i 's/^max_log_file =.*/max_log_file = 100/' /etc/audit/auditd.conf
# CIS 6.2.2.2 - Don't auto-delete
sed -i 's/^max_log_file_action =.*/max_log_file_action = keep_logs/' /etc/audit/auditd.conf
# CIS 6.2.2.4 - Warn when low on space
sed -i 's/^space_left_action =.*/space_left_action = email/' /etc/audit/auditd.conf
sed -i 's/^admin_space_left_action =.*/admin_space_left_action = halt/' /etc/audit/auditd.conf

# CIS 6.2.1.3 - Audit processes before auditd starts
if ! grep -q "audit=1" /etc/default/grub; then
  sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 audit=1 audit_backlog_limit=8192"/' /etc/default/grub
  update-grub >> "$LOG_FILE" 2>&1
  log "Added audit=1 to GRUB_CMDLINE_LINUX"
fi

# Write full CIS-aligned audit rules
cat > /etc/audit/rules.d/99-cis.rules <<'EOF'
## CIS Ubuntu 24.04 LTS Benchmark - Audit Rules
-D
-b 8192
-f 1
--backlog_wait_time 60000

# CIS 6.2.3.4 - Date/time changes
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# CIS 6.2.3.8 - User/group info changes
-w /etc/group   -p wa -k identity
-w /etc/passwd  -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow  -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# CIS 6.2.3.5 - Network environment changes
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale
-w /etc/issue     -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts     -p wa -k system-locale
-w /etc/networks  -p wa -k system-locale
-w /etc/network/  -p wa -k system-locale

# CIS 6.2.3.14 - MAC policy changes (AppArmor)
-w /etc/apparmor/       -p wa -k MAC-policy
-w /etc/apparmor.d/     -p wa -k MAC-policy

# CIS 6.2.3.9 - DAC permission modifications
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod

# CIS 6.2.3.7 - Unsuccessful file access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM  -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM  -F auid>=1000 -F auid!=4294967295 -k access

# CIS 6.2.3.6 - Privileged commands
-a always,exit -F path=/usr/bin/chsh   -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/chfn   -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/newgrp -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/mount  -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/umount -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/sudo   -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/bin/su     -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/useradd  -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/userdel  -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/usermod  -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/groupadd -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/groupdel -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/groupmod -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd
-a always,exit -F path=/usr/sbin/passwd    -F perm=x -F auid>=1000 -F auid!=4294967295 -k priv_cmd

# CIS 6.2.3.10 - Successful filesystem mounts
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts

# CIS 6.2.3.13 - File deletion
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# CIS 6.2.3.1 - Sudoers changes
-w /etc/sudoers   -p wa -k scope
-w /etc/sudoers.d -p wa -k scope

# CIS 6.2.3.2 - Actions as another user (sudo log)
-a always,exit -F arch=b64 -C euid!=uid -F euid=0 -S execve -k actions
-a always,exit -F arch=b32 -C euid!=uid -F euid=0 -S execve -k actions

# CIS 6.2.3.3 - Sudo log file changes
-w /var/log/sudo.log -p wa -k sudo_log_file

# CIS 6.2.3.11 / 6.2.3.12 - Session / login-logout
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session
-w /var/log/lastlog -p wa -k logins
-w /var/log/faillog -p wa -k logins

# CIS 6.2.3.19 - Kernel module loading
-w /sbin/insmod    -p x -k modules
-w /sbin/rmmod     -p x -k modules
-w /sbin/modprobe  -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# CIS 6.2.3.15/16/17 - chcon, setfacl, chacl
-a always,exit -F path=/usr/bin/chcon   -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng
-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng
-a always,exit -F path=/usr/bin/chacl   -F perm=x -F auid>=1000 -F auid!=4294967295 -k perm_chng 2>/dev/null || true

# CIS 6.2.3.18 - usermod
-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=4294967295 -k usermod

# CIS 6.2.3.20 - Immutable (must be last)
-e 2
EOF

# Fix permissions on audit config (CIS 6.2.4.5/6/7)
chmod 640 /etc/audit/rules.d/99-cis.rules
chown root:root /etc/audit/rules.d/99-cis.rules

systemctl enable auditd
systemctl restart auditd
log "auditd configured with full CIS rule set."

# =============================================================================
header "10. Rsyslog (CIS 6.1.3.x)"
# =============================================================================
log "Configuring rsyslog..."
systemctl enable rsyslog
systemctl start rsyslog

# CIS 6.1.3.4 - Log file creation mode
if ! grep -q "FileCreateMode" /etc/rsyslog.conf; then
  echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
else
  sed -i 's/^\$FileCreateMode.*/\$FileCreateMode 0640/' /etc/rsyslog.conf
fi

# CIS 6.1.3.7 - Not receiving remote logs
sed -i 's/^#\?\s*module(load="imudp")/# module(load="imudp")/' /etc/rsyslog.conf
sed -i 's/^#\?\s*input(type="imudp"/# input(type="imudp"/' /etc/rsyslog.conf
sed -i 's/^#\?\s*module(load="imtcp")/# module(load="imtcp")/' /etc/rsyslog.conf
sed -i 's/^#\?\s*input(type="imtcp"/# input(type="imtcp"/' /etc/rsyslog.conf

systemctl restart rsyslog
log "rsyslog configured."

# =============================================================================
header "11. Journald (CIS 6.1.2.x)"
# =============================================================================
log "Configuring journald..."
mkdir -p /etc/systemd/journald.conf.d/
cat > /etc/systemd/journald.conf.d/cis.conf <<'EOF'
[Journal]
# CIS 6.1.2.3 - Compress large files
Compress=yes
# CIS 6.1.2.4 - Write to disk
Storage=persistent
# CIS 6.1.2.2 - Don't forward to syslog (avoid conflict)
ForwardToSyslog=no
EOF

systemctl restart systemd-journald
log "journald configured."

# =============================================================================
header "12. AppArmor (CIS 1.3.x)"
# =============================================================================
log "Ensuring AppArmor is active and enforcing..."
systemctl enable apparmor
systemctl start apparmor
aa-enforce /etc/apparmor.d/* 2>/dev/null || true
log "AppArmor enforcing."

# =============================================================================
header "13. AIDE File Integrity (CIS 6.3.x)"
# =============================================================================
log "Initialising AIDE database (may take a few minutes)..."
mkdir -p /var/log/aide
aideinit -y -f >> "$LOG_FILE" 2>&1 || true
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null || true

# CIS 6.3.2 - Regular integrity checks
cat > /etc/cron.d/aide-cis <<'EOF'
# CIS 6.3.2 - Daily filesystem integrity check
0 5 * * * root /usr/bin/aide --check >> /var/log/aide/aide-check.log 2>&1
EOF

# CIS 6.3.3 - Cryptographic protection of audit tools (via AIDE)
log "AIDE configured with daily check at 05:00."

# =============================================================================
header "14. Sudo Hardening (CIS 5.2.x)"
# =============================================================================
log "Configuring sudo..."
# CIS 5.2.2 - sudo commands use pty
# CIS 5.2.3 - sudo log file
# CIS 5.2.6 - timeout
cat > /etc/sudoers.d/99-cis <<'EOF'
# CIS 5.2.2 - Use pty for sudo
Defaults use_pty
# CIS 5.2.3 - Sudo log file
Defaults logfile="/var/log/sudo.log"
# CIS 5.2.6 - Re-auth timeout (5 min)
Defaults timestamp_timeout=5
EOF
chmod 440 /etc/sudoers.d/99-cis
log "Sudo CIS settings applied."

# =============================================================================
header "15. Cron Hardening (CIS 2.4.x)"
# =============================================================================
log "Hardening cron permissions..."
# CIS 2.4.1.2 - /etc/crontab permissions
chmod 600 /etc/crontab
chown root:root /etc/crontab

# CIS 2.4.1.3-7 - cron directories
for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
  if [[ -d "$dir" ]]; then
    chmod 700 "$dir"
    chown root:root "$dir"
  fi
done

# CIS 2.4.1.8 / 2.4.2.1 - Restrict cron/at to authorised users
echo "root" > /etc/cron.allow
chmod 600 /etc/cron.allow
rm -f /etc/cron.deny

echo "root" > /etc/at.allow
chmod 600 /etc/at.allow
rm -f /etc/at.deny

log "Cron hardened."

# =============================================================================
header "16. Kernel Hardening - sysctl (CIS 3.3.x)"
# =============================================================================
log "Applying sysctl hardening..."
cat > /etc/sysctl.d/99-cis.conf <<'EOF'
# CIS 3.3.1 - IP forwarding disabled
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# CIS 3.3.2 - Packet redirect sending disabled
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# CIS 3.3.3 - Bogus ICMP ignored
net.ipv4.icmp_ignore_bogus_error_responses = 1

# CIS 3.3.4 - Broadcast ICMP ignored
net.ipv4.icmp_echo_ignore_broadcasts = 1

# CIS 3.3.5 / 3.3.6 - ICMP redirects not accepted
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# CIS 3.3.7 - Reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# CIS 3.3.8 - Source routed packets not accepted
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# CIS 3.3.9 - Suspicious packets logged
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# CIS 3.3.10 - TCP SYN cookies
net.ipv4.tcp_syncookies = 1

# CIS 3.3.11 - IPv6 router advertisements not accepted
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# CIS 1.5.1 - ASLR
kernel.randomize_va_space = 2

# CIS 1.5.2 - ptrace scope
kernel.yama.ptrace_scope = 1

# CIS 1.5.3 - Core dumps restricted
fs.suid_dumpable = 0

# Additional kernel hardening
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2
EOF

sysctl -p /etc/sysctl.d/99-cis.conf >> "$LOG_FILE" 2>&1
log "sysctl CIS hardening applied."

# =============================================================================
header "17. Core Dumps Restricted (CIS 1.5.3)"
# =============================================================================
if ! grep -q "* hard core 0" /etc/security/limits.conf; then
  echo "* hard core 0" >> /etc/security/limits.conf
  echo "* soft core 0" >> /etc/security/limits.conf
fi

cat > /etc/sysctl.d/99-coredump.conf <<'EOF'
kernel.core_pattern = |/bin/false
fs.suid_dumpable = 0
EOF
sysctl -p /etc/sysctl.d/99-coredump.conf >> "$LOG_FILE" 2>&1

if systemctl is-active systemd-coredump.socket &>/dev/null; then
  mkdir -p /etc/systemd/coredump.conf.d/
  cat > /etc/systemd/coredump.conf.d/cis.conf <<'EOF'
[Coredump]
Storage=none
ProcessSizeMax=0
EOF
fi
log "Core dumps restricted."

# =============================================================================
header "18. Legal Banners (CIS 1.6.x)"
# =============================================================================
cat > /etc/issue <<'EOF'
Authorized use only. All activity is monitored and logged.
EOF

cat > /etc/issue.net <<'EOF'
*******************************************************************************
WARNING: Unauthorized access to this system is strictly prohibited.
All connections, commands, and activities are monitored and logged.
Disconnect IMMEDIATELY if you are not an authorized user.
*******************************************************************************
EOF

cat > /etc/motd <<'EOF'
Authorized use only. All activity is monitored and logged.
EOF

chmod 644 /etc/issue /etc/issue.net /etc/motd
chown root:root /etc/issue /etc/issue.net /etc/motd
log "Legal banners configured."

# =============================================================================
header "19. File Permissions (CIS 7.1.x)"
# =============================================================================
log "Setting critical file permissions..."
chmod 644 /etc/passwd && chown root:root /etc/passwd
chmod 640 /etc/shadow && chown root:shadow /etc/shadow
chmod 644 /etc/group  && chown root:root /etc/group
chmod 640 /etc/gshadow && chown root:shadow /etc/gshadow
[[ -f /etc/passwd- ]]  && chmod 644 /etc/passwd-  && chown root:root /etc/passwd-
[[ -f /etc/shadow- ]]  && chmod 640 /etc/shadow-  && chown root:shadow /etc/shadow-
[[ -f /etc/group- ]]   && chmod 644 /etc/group-   && chown root:root /etc/group-
[[ -f /etc/gshadow- ]] && chmod 640 /etc/gshadow- && chown root:shadow /etc/gshadow-
[[ -f /etc/shells ]]   && chmod 644 /etc/shells
[[ -f /etc/security/opasswd ]] && chmod 600 /etc/security/opasswd && chown root:root /etc/security/opasswd
log "File permissions set."

# =============================================================================
header "20. Unattended Security Upgrades (CIS 1.2.2.1)"
# =============================================================================
log "Configuring automatic security updates..."
cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF
log "Unattended security upgrades enabled."

# =============================================================================
header "Pre-Hardening Complete"
# =============================================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         PRE-HARDENING COMPLETE ✓                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}SSH:${NC}           Port 22, password auth, CIS-compliant config"
echo -e "  ${CYAN}UFW:${NC}           Enabled, default deny, port 22 open, loopback OK"
echo -e "  ${CYAN}Fail2Ban:${NC}      Active - bans after 4 failures for 15 minutes"
echo -e "  ${CYAN}auditd:${NC}        Active with full CIS rule set"
echo -e "  ${CYAN}rsyslog:${NC}       Active and configured"
echo -e "  ${CYAN}journald:${NC}      Persistent, compressed"
echo -e "  ${CYAN}AppArmor:${NC}      Enforcing"
echo -e "  ${CYAN}AIDE:${NC}          Initialised, daily check at 05:00"
echo -e "  ${CYAN}sysctl:${NC}        All CIS 3.3.x kernel settings applied"
echo -e "  ${CYAN}Chrony:${NC}        Time sync active"
echo -e "  ${CYAN}Sudo:${NC}          CIS 5.2.x settings applied"
echo -e "  ${CYAN}File perms:${NC}    CIS 7.1.x permissions set"
echo -e "  ${CYAN}Log:${NC}           $LOG_FILE"
echo ""

if [[ -n "$CIS_KIT_DIR" ]]; then
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}NEXT STEP: Run the CIS Build Kit:${NC}"
  echo -e "  cd $CIS_KIT_DIR"
  echo -e "  sudo bash ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh"
  echo -e "${YELLOW}Select profile: L1S (Level 1 Server) when prompted${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}NEXT STEPS:${NC}"
  echo -e "  1. Copy exclusion_list.txt to your CIS kit folder"
  echo -e "  2. Run: sudo bash ubuntu_linux_24.04_lts_benchmark_v1.0.0.sh"
  echo -e "  3. Select profile: L1S (Level 1 Server)"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
warn "A reboot is recommended after running the CIS kit."
warn "Test SSH on port 22 in a NEW terminal before rebooting."
