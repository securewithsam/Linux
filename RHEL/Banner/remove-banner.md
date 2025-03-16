To **remove all previously set login banners** on your **RHEL 9** system, follow these steps:

---

## **1️⃣ Remove Pre-Login Banner (Before Authentication)**  
Delete the `/etc/issue.net` file:
```bash
sudo rm -f /etc/issue.net
```

Restore the **default SSH configuration**:  
```bash
sudo sed -i 's|Banner /etc/issue.net|#Banner none|' /etc/ssh/sshd_config
sudo systemctl restart sshd
```
✔️ **SSH will no longer show a pre-login banner.**

---

## **2️⃣ Remove Post-Login Banner (Message of the Day)**  
Reset `/etc/motd` to default:
```bash
echo "" | sudo tee /etc/motd
```
✔️ **Users will no longer see a message after login.**

---

## **3️⃣ Remove Custom Message for `security` User**  
Remove the **custom `.bashrc` entry** for the `security` user:
```bash
sudo sed -i '/SECURITY TEAM SANDBOX/d' /home/security/.bashrc
sudo sed -i '/Be careful! All commands are monitored and audited./d' /home/security/.bashrc
sudo sed -i '/CIS_RHEL9_v2BuildKit/d' /home/security/.bashrc
```
✔️ **The `security` user will no longer see a custom message upon login.**

---

### **✅ Summary**
✔️ **Pre-login SSH banner removed**  
✔️ **Post-login (MOTD) message removed**  
✔️ **Custom `.bashrc` login message removed**  

Let me know if you need further changes! 🚀
