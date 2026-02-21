Here's a clean summary of everything the script hardens and why it matters:

---

### 1. System Updates & Auto-Upgrades
Applies all pending patches immediately and enables automatic security updates going forward. Most breaches exploit known vulnerabilities that already have patches available — keeping the system current closes that window.

### 2. Remove Unnecessary Packages
Removes telnet, ftp, rsh, nis and other legacy tools. Every installed package is a potential attack surface. Tools like telnet transmit credentials in plain text — there's no reason they should exist on a hardened server.

### 3. SSH Hardening (Port 35000)
Moves SSH off the default port 22, disables root login, blocks empty passwords, limits auth attempts to 4, disables X11/TCP forwarding, and enforces modern ciphers only. Port 22 is scanned by automated bots constantly — moving to 35000 eliminates the majority of that noise. Disabling root login means attackers need to know both a valid username AND password. Weak ciphers like RC4 and MD5-based MACs are blocked entirely.

### 4. UFW Firewall
Default deny on all incoming traffic, only port 35000 is open. Loopback (lo) is explicitly allowed so internal services communicate normally. Every closed port is an attack vector eliminated. Default deny means nothing gets in unless you explicitly allow it.

### 5. Fail2Ban
Monitors SSH login attempts and automatically bans IPs after 5 failures for 1 hour. Stops brute force and credential stuffing attacks dead. Without this, an attacker can try thousands of password combinations unimpeded.

### 6. Kernel Hardening (sysctl)
A broad set of kernel-level protections covering SYN flood protection, IP spoofing prevention, disabling ICMP broadcast responses, blocking redirects, disabling IPv6 if unused, ASLR (memory randomisation), restricting ptrace, hiding kernel pointers, and disabling SysRq. These close off a large class of network-level attacks and memory exploitation techniques. ASLR alone makes most buffer overflow exploits unreliable.

### 7. Audit Daemon (auditd)
Logs every write to sensitive files like `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, every sudo command run, every file deletion, kernel module load, and login event. Creates a forensic trail — if something goes wrong you can reconstruct exactly what happened, when, and under which user. Also required for most compliance frameworks (PCI-DSS, ISO 27001, SOC2).

### 8. AppArmor
Enforces mandatory access control profiles on applications — confines what files, network sockets, and capabilities each program can access. Even if an application is compromised, AppArmor limits what damage it can do by restricting it to its profile.

### 9. Disable Unnecessary Services
Stops and disables avahi (network discovery), cups (printing), bluetooth, apport (crash reporting), and whoopsie (Ubuntu error reporting). Each running service is a potential entry point. A server has no business running a print daemon or Bluetooth stack.

### 10. Disable Uncommon Network Protocols
Blacklists DCCP, SCTP, RDS, and TIPC kernel modules. These are rarely used protocols with a history of serious kernel vulnerabilities. If your server doesn't need them, they shouldn't be loadable at all.

### 11. Sudo Hardening
Requires password re-entry after 5 minutes of inactivity and logs every sudo command to `/var/log/sudo.log`. Prevents someone walking up to an unattended terminal and running privileged commands, and gives you a full audit trail of privilege use.

### 12. Legal Banners
Displays a warning on SSH login and console. Establishes legal notice that the system is monitored — relevant if you ever need to pursue unauthorised access legally, as it removes any "I didn't know" defence.

### 13. AIDE (File Integrity Monitoring)
Takes a cryptographic baseline snapshot of the filesystem and runs a daily comparison at 03:00. If any system binary, config file, or library is modified — by an attacker, a rootkit, or anything else — AIDE will detect and report the change. This is your last line of defence for detecting a compromise that got through everything else.

---

**The overall philosophy** is defence in depth — no single control stops everything, but each layer raises the cost and difficulty for an attacker. By the time someone gets through fail2ban, the firewall, SSH hardening, AppArmor, and kernel protections, auditd and AIDE will have already flagged the intrusion.
