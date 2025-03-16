To include an indication that this system is a **CIS-hardened RHEL 9 build (CIS_RHEL9_v2BuildKit)** in the **login banners**, follow these steps:

---

## **1️⃣ Pre-Login Banner (Before Authentication)**
This will be shown **before login (SSH or local terminal).**

### **Set Up `/etc/issue.net`**
```bash
echo "************************************************" | sudo tee /etc/issue.net
echo "*      🚀 SECURITY TEAM SANDBOX 🚀             *" | sudo tee -a /etc/issue.net
echo "*   ⚠️ Be careful! All commands are          *" | sudo tee -a /etc/issue.net
echo "*    monitored and audited. ⚠️               *" | sudo tee -a /etc/issue.net
echo "*   📌 System: CIS_RHEL9_v2BuildKit           *" | sudo tee -a /etc/issue.net
echo "************************************************" | sudo tee -a /etc/issue.net
```

### **Configure SSH to Display This Banner**
```bash
sudo sed -i 's|#Banner none|Banner /etc/issue.net|' /etc/ssh/sshd_config
sudo systemctl restart sshd
```
✔️ **Now, this banner will be displayed when users connect via SSH.**

---

## **2️⃣ Post-Login Banner (After Authentication)**
This message appears **after successful login.**

### **Set Up `/etc/motd` (Message of the Day)**
```bash
echo "🚀 Welcome to SECURITY TEAM SANDBOX 🚀" | sudo tee /etc/motd
echo "⚠️ Be careful! All commands are monitored and audited. ⚠️" | sudo tee -a /etc/motd
echo "📌 System: CIS_RHEL9_v2BuildKit - CIS Hardened RHEL 9" | sudo tee -a /etc/motd
```
✔️ **Users will see this message after logging in.**

---

## **3️⃣ Custom Message for `security` User (Every Login)**
To show this warning **every time `security` logs in**, modify `.bashrc`:

```bash
echo "echo -e '\n🚀 SECURITY TEAM SANDBOX 🚀\n⚠️ Be careful! All commands are monitored and audited. ⚠️\n📌 System: CIS_RHEL9_v2BuildKit - CIS Hardened RHEL 9\n'" | sudo tee -a /home/security/.bashrc
```
✔️ **The `security` user will see this warning on every login.**

---

## **🔹 Example Output**
### **Before Login (SSH or Console):**
```
************************************************
*      🚀 SECURITY TEAM SANDBOX 🚀             *
*   ⚠️ Be careful! All commands are          *
*    monitored and audited. ⚠️               *
*   📌 System: CIS_RHEL9_v2BuildKit           *
************************************************
```

### **After Login:**
```
🚀 Welcome to SECURITY TEAM SANDBOX 🚀
⚠️ Be careful! All commands are monitored and audited. ⚠️
📌 System: CIS_RHEL9_v2BuildKit - CIS Hardened RHEL 9
```

This ensures that all users are aware they are in a **CIS-hardened RHEL 9** system and that their actions are monitored. Let me know if you need further adjustments! 🚀🔥
