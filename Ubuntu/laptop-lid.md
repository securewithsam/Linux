Ubuntu behavior. When you close the lid, it suspends → SSH dies. You need to disable **lid-triggered sleep + system suspend**.

Here’s the clean way (works for lab/24x7 use):

---

## ✅ 1. Disable sleep on lid close (most important)

Edit the systemd logind config:

```bash
sudo nano /etc/systemd/logind.conf
```

Find these lines (uncomment if needed) and set:

```ini
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
```

Save and exit.

---

## ✅ 2. Restart the service

```bash
sudo systemctl restart systemd-logind
```

---

## ✅ 3. Disable suspend/hibernate completely (recommended for lab)

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

This ensures it **never goes to sleep** unexpectedly.

---

## ✅ 4. Optional: Disable GUI power settings (if desktop installed)

If you're using Ubuntu Desktop:

```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
```

---

## ✅ 5. Test it

1. SSH into the box
2. Close the lid
3. Try reconnecting SSH → should stay alive

---

## 🔒 Quick Security Note (since you're running a lab)

Since this will be **always-on**, consider:

* Set static IP or DHCP reservation
* Enable firewall:

  ```bash
  sudo ufw allow ssh
  sudo ufw enable
  ```
