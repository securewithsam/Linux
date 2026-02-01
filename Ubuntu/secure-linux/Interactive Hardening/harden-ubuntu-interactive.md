#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Interactive Ubuntu 24.04 hardening script
# Balanced for Proofpoint DSPM scanner hosts (Docker-based)
###############################################################################

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo)." >&2
  exit 1
fi

echo
echo "=============================================="
echo " Ubuntu 24.04 Interactive Hardening (DSPM)"
echo "=============================================="
echo

read -rp "Proceed with system hardening? (y/n) [y]: " PROCEED
PROCEED=${PROCEED:-y}
[[ "$PROCEED" != "y" ]] && exit 0

###############################################################################
# OS PATCHING
###############################################################################
read -rp "Apply OS updates and enable security auto-updates? (y/n) [y]: " DO_UPDATES
DO_UPDATES=${DO_UPDATES:-y}

if [[ "$DO_UPDATES" == "y" ]]; then
  echo "[+] Updating system..."
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt dist-upgrade -y
  apt install -y unattended-upgrades
  systemctl enable --now unattended-upgrades
fi

###############################################################################
# SSH HARDENING
###############################################################################
read -rp "Harden SSH (disable root login, disable password auth)? (y/n) [y]: " HARDEN_SSH
HARDEN_SSH=${HARDEN_SSH:-y}

if [[ "$HARDEN_SSH" == "y" ]]; then
  read -rp "SSH port to use? [22]: " SSH_PORT
  SSH_PORT=${SSH_PORT:-22}

  echo "[+] Applying SSH hardening..."
  mkdir -p /etc/ssh/sshd_config.d

  cat >/etc/ssh/sshd_config.d/99-dspm-hardening.conf <<EOF
Port ${SSH_PORT}
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 4
EOF

  sshd -t && systemctl restart ssh
fi

###############################################################################
# FIREWALL (UFW)
###############################################################################
read -rp "Enable and configure UFW firewall? (y/n) [y]: " ENABLE_UFW
ENABLE_UFW=${ENABLE_UFW:-y}

if [[ "$ENABLE_UFW" == "y" ]]; then
  apt install -y ufw

  read -rp "Management CIDR allowed for SSH? [10.0.0.0/8]: " MGMT_CIDR
  MGMT_CIDR=${MGMT_CIDR:-10.0.0.0/8}

  read -rp "Additional inbound ports to allow (comma-separated, or empty)? []: " EXTRA_PORTS

  echo "[+] Configuring UFW..."
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow from "$MGMT_CIDR" to any port "$SSH_PORT" proto tcp

  if [[ -n "$EXTRA_PORTS" ]]; then
    IFS=',' read -ra PORTS <<<"$EXTRA_PORTS"
    for p in "${PORTS[@]}"; do
      ufw allow "$p"
    done
  fi

  ufw --force enable
  ufw status verbose
fi

###############################################################################
# FAIL2BAN
###############################################################################
read -rp "Enable Fail2ban for SSH brute-force protection? (y/n) [y]: " ENABLE_F2B
ENABLE_F2B=${ENABLE_F2B:-y}

if [[ "$ENABLE_F2B" == "y" ]]; then
  apt install -y fail2ban
  cat >/etc/fail2ban/jail.d/sshd-dspm.conf <<EOF
[sshd]
enabled = true
port = ${SSH_PORT}
maxretry = 5
findtime = 10m
bantime = 1h
EOF
  systemctl enable --now fail2ban
fi

###############################################################################
# TIME SYNC
###############################################################################
read -rp "Ensure time sync (chrony) is enabled? (y/n) [y]: " ENABLE_TIME
ENABLE_TIME=${ENABLE_TIME:-y}

if [[ "$ENABLE_TIME" == "y" ]]; then
  apt install -y chrony
  systemctl enable --now chrony
fi

###############################################################################
# SYSCTL NETWORK HARDENING
###############################################################################
read -rp "Apply conservative kernel/network hardening? (y/n) [y]: " ENABLE_SYSCTL
ENABLE_SYSCTL=${ENABLE_SYSCTL:-y}

if [[ "$ENABLE_SYSCTL" == "y" ]]; then
  cat >/etc/sysctl.d/99-dspm-hardening.conf <<'EOF'
net.ipv4.ip_forward=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
EOF
  sysctl --system
fi

###############################################################################
# DOCKER BASELINE
###############################################################################
read -rp "Apply Docker baseline (log rotation, live-restore)? (y/n) [y]: " DO_DOCKER
DO_DOCKER=${DO_DOCKER:-y}

if [[ "$DO_DOCKER" == "y" && -x "$(command -v docker)" ]]; then
  mkdir -p /etc/docker
  cat >/etc/docker/daemon.json <<'EOF'
{
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "5"
  }
}
EOF
  systemctl restart docker
fi

###############################################################################
# SERVICE MINIMIZATION
###############################################################################
read -rp "Disable common unused services (avahi, bluetooth, cups)? (y/n) [y]: " DISABLE_SVC
DISABLE_SVC=${DISABLE_SVC:-y}

if [[ "$DISABLE_SVC" == "y" ]]; then
  for svc in avahi-daemon bluetooth cups; do
    systemctl disable --now "$svc" 2>/dev/null || true
  done
fi

###############################################################################
# SUMMARY
###############################################################################
echo
echo "=============================================="
echo " Hardening Complete"
echo "=============================================="
echo "✔ SSH hardened (if enabled)"
echo "✔ Firewall applied (if enabled)"
echo "✔ Docker baseline applied (if enabled)"
echo "✔ System patched (if enabled)"
echo
echo "IMPORTANT: Verify SSH access in a new session before closing this one."
echo
