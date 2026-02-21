#!/bin/bash
# =============================================================================
# Ubuntu 24.04 LTS Enterprise Hardening Script - SAFE EDITION
# SSH Port: 35000 | Password Auth | No lockout risks
# Run as root: sudo bash harden-ubuntu24.sh
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SSH_PORT=35000
LOG_FILE="/var/log/hardening-$(date +%Y%m%d-%H%M%S).log"

log()    { echo -e "${GREEN}[+]${NC} $1" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()    { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
header() { echo -e "\n${CYAN}=== $1 ===${NC}" | tee -a "$LOG_FILE"; }

if [[ $EUID -ne 0 ]]; then
  err "Run as root: sudo bash $0"
  exit 1
fi

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║     Ubuntu 24.04 Enterprise Hardening Script     ║"
echo "  ║     SSH Port: 35000  |  Safe Edition             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Log: $LOG_FILE"
echo ""
warn "SSH will move to port $SSH_PORT. Ensure port $SSH_PORT is open upstream."
warn "Open a second terminal and test SSH on port $SSH_PORT before closing this session."
read -rp "Continue? (yes/no): " CONFIRM
[[ "$CONFIRM" != "yes" ]] && { echo "Aborted."; exit 0; }

# =============================================================================
header "1. System Updates"
# =============================================================================
log "Updating system..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
apt-get autoremove -y -qq

log "Configuring unattended security upgrades..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq unattended-upgrades

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

log "Unattended upgrades configured."

# =============================================================================
header "2. Remove Unnecessary Packages"
# =============================================================================
REMOVE_PKGS="telnet rsh-client ftp xinetd nis talk talkd"
for pkg in $REMOVE_PKGS; do
  if dpkg -l "$pkg" &>/dev/null 2>&1; then
    apt-get purge -y -qq "$pkg" && log "Removed: $pkg"
  fi
done
apt-get autoremove -y -qq

# =============================================================================
header "3. SSH Hardening (Port $SSH_PORT, Password Auth)"
# =============================================================================
log "Backing up sshd_config..."
cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%Y%m%d)"

log "Writing hardened sshd_config..."
cat > /etc/ssh/sshd_config <<EOF
# Hardened SSH Configuration - $(date)
Protocol 2
Port $SSH_PORT

# Authentication - password based
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication yes
UsePAM yes

# Session limits
MaxAuthTries 4
MaxSessions 5
LoginGraceTime 60

# Forwarding (disabled)
AllowTcpForwarding no
X11Forwarding no
AllowAgentForwarding no
PermitTunnel no

# Keep-alive
ClientAliveInterval 300
ClientAliveCountMax 2

# Misc
PermitUserEnvironment no
Compression no
PrintLastLog yes
Banner /etc/issue.net

# Strong ciphers only
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
EOF

chmod 600 /etc/ssh/sshd_config

log "Validating SSH config..."
if sshd -t; then
  log "SSH config valid."
  systemctl daemon-reload
  systemctl restart ssh
  sleep 2
  systemctl is-active ssh && log "SSH running on port $SSH_PORT." || err "SSH failed to start!"
else
  err "SSH config invalid! Restoring backup."
  cp "/etc/ssh/sshd_config.bak.$(date +%Y%m%d)" /etc/ssh/sshd_config
  systemctl daemon-reload
  systemctl restart ssh
fi

# =============================================================================
header "4. UFW Firewall"
# =============================================================================
log "Installing UFW..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ufw

log "Resetting UFW to clean state..."
ufw --force reset

log "Setting default policies..."
ufw default deny incoming
ufw default allow outgoing

# Loopback (lo) - UFW always permits loopback internally, no rule needed.
# Explicitly allow it anyway for clarity.
ufw allow in on lo
ufw deny in from 127.0.0.0/8
ufw deny in from ::1

log "Allowing SSH on port $SSH_PORT..."
ufw allow "$SSH_PORT"/tcp comment 'SSH'

ufw logging on

log "Enabling UFW..."
ufw --force enable

# Restart SSH after UFW enable to ensure it's still running
sleep 2
systemctl restart ssh
log "SSH restarted post-UFW to ensure connectivity."

log "UFW enabled. Current status:"
ufw status verbose | tee -a "$LOG_FILE"

# =============================================================================
header "5. Fail2Ban"
# =============================================================================
log "Installing fail2ban..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq fail2ban

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5
backend  = systemd

[sshd]
enabled  = true
port     = $SSH_PORT
logpath  = %(sshd_log)s
backend  = systemd
maxretry = 5
bantime  = 3600
findtime = 600
EOF

systemctl enable fail2ban
systemctl restart fail2ban
log "Fail2ban active - bans after 5 failures for 1 hour."

# =============================================================================
header "6. Kernel Hardening (sysctl)"
# =============================================================================
log "Applying sysctl hardening..."
cat > /etc/sysctl.d/99-hardening.conf <<'EOF'
# Anti-spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ICMP
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Logging martians
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Disable IPv6 (remove if you use IPv6)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# No IP forwarding
net.ipv4.ip_forward = 0

# Kernel memory / process protections
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.sysrq = 0
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2
EOF

sysctl -p /etc/sysctl.d/99-hardening.conf >> "$LOG_FILE" 2>&1
log "sysctl hardening applied."

# =============================================================================
header "7. Audit Daemon (auditd)"
# =============================================================================
log "Installing auditd..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq auditd audispd-plugins

cat > /etc/audit/rules.d/99-hardening.rules <<'EOF'
-D
-b 8192
-f 1

# Auth & identity files
-w /etc/passwd       -p wa -k identity
-w /etc/shadow       -p wa -k identity
-w /etc/group        -p wa -k identity
-w /etc/gshadow      -p wa -k identity
-w /etc/sudoers      -p wa -k sudoers
-w /etc/sudoers.d/   -p wa -k sudoers

# SSH config
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Sudo usage
-w /usr/bin/sudo     -p x -k sudo_use
-a always,exit -F arch=b64 -S execve -F euid=0 -k admin_cmds

# Logins
-w /var/log/lastlog  -p wa -k logins
-w /var/log/faillog  -p wa -k logins

# Cron
-w /etc/crontab      -p wa -k cron
-w /etc/cron.d/      -p wa -k cron

# Kernel modules
-w /sbin/insmod      -p x -k modules
-w /sbin/rmmod       -p x -k modules
-w /sbin/modprobe    -p x -k modules

# File deletion
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -k delete

# Make rules immutable until reboot
-e 2
EOF

systemctl enable auditd
systemctl restart auditd
log "auditd configured and started."

# =============================================================================
header "8. AppArmor"
# =============================================================================
log "Ensuring AppArmor is active..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apparmor apparmor-utils

systemctl enable apparmor
systemctl start apparmor
aa-enforce /etc/apparmor.d/* 2>/dev/null || true
log "AppArmor set to enforce."

# =============================================================================
header "9. Disable Unnecessary Services"
# =============================================================================
DISABLE_SERVICES="avahi-daemon cups bluetooth apport whoopsie"
for svc in $DISABLE_SERVICES; do
  if systemctl is-enabled "$svc" &>/dev/null 2>&1; then
    systemctl disable --now "$svc" && log "Disabled: $svc"
  fi
done

# =============================================================================
header "10. Disable Uncommon Network Protocols"
# =============================================================================
cat > /etc/modprobe.d/disable-protocols.conf <<'EOF'
install dccp /bin/false
install sctp /bin/false
install rds  /bin/false
install tipc /bin/false
EOF
log "Uncommon network protocols disabled."

# =============================================================================
header "11. Sudo Hardening (Safe)"
# =============================================================================
cat > /etc/sudoers.d/99-hardening <<'EOF'
# Re-prompt password after 5 mins inactivity
Defaults    timestamp_timeout=5
# Log all sudo commands
Defaults    logfile="/var/log/sudo.log"
EOF
chmod 440 /etc/sudoers.d/99-hardening
log "Sudo hardening applied."

# =============================================================================
header "12. Legal Banners"
# =============================================================================
cat > /etc/issue.net <<'EOF'
*******************************************************************************
WARNING: Unauthorized access to this system is strictly prohibited.
All connections and activity are monitored and logged.
Disconnect IMMEDIATELY if you are not an authorized user.
*******************************************************************************
EOF

cat > /etc/motd <<'EOF'
================================================================================
  NOTICE: Authorized use only. All activity is monitored and logged.
================================================================================
EOF
log "Legal banners set."

# =============================================================================
header "13. AIDE File Integrity Monitoring"
# =============================================================================
log "Installing AIDE (may take a few minutes)..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq aide aide-common
aideinit -y -f >> "$LOG_FILE" 2>&1 || true
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null || true
mkdir -p /var/log/aide
cat > /etc/cron.d/aide-check <<'EOF'
0 3 * * * root /usr/bin/aide --check >> /var/log/aide/aide-check.log 2>&1
EOF
log "AIDE installed, daily integrity check at 03:00."

# =============================================================================
header "Done - Summary"
# =============================================================================
echo ""
echo -e "${CYAN}--- Final UFW Status ---${NC}"
ufw status verbose | tee -a "$LOG_FILE"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           HARDENING COMPLETE ✓                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}SSH Port:${NC}     $SSH_PORT (password auth, root login disabled)"
echo -e "  ${CYAN}Fail2Ban:${NC}     Active — bans after 5 failures for 1 hour"
echo -e "  ${CYAN}UFW:${NC}          Enabled — default deny, loopback allowed, port $SSH_PORT open"
echo -e "  ${CYAN}auditd:${NC}       Active"
echo -e "  ${CYAN}AppArmor:${NC}     Enforcing"
echo -e "  ${CYAN}AIDE:${NC}         Daily integrity check at 03:00"
echo -e "  ${CYAN}Passwords:${NC}    Unchanged — no expiry or complexity changes made"
echo -e "  ${CYAN}Log:${NC}          $LOG_FILE"
echo ""
echo -e "${YELLOW}⚠  Before closing this session, test in a NEW terminal:${NC}"
echo -e "   ssh -p $SSH_PORT youruser@<server-ip>"
echo ""
read -rp "Reboot now to fully apply all changes? (yes/no): " REBOOT_NOW
if [[ "$REBOOT_NOW" == "yes" ]]; then
  log "Rebooting..."
  reboot
else
  warn "Remember to reboot before putting this system into production."
fi
