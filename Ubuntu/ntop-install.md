# 1. Prerequisites
sudo apt-get install -y software-properties-common wget
sudo add-apt-repository universe -y

# 2. Add ntop official repository
wget https://packages.ntop.org/apt-stable/24.04/all/apt-ntop-stable.deb
sudo apt install -y ./apt-ntop-stable.deb

# 3. Update system
sudo apt-get clean all
sudo apt-get update
sudo apt-get upgrade -y

# 4. Install ntopng and related components
sudo apt-get install -y pfring-dkms nprobe ntopng n2disk cento ntap

# 5. (Optional) PF_RING ZC drivers – only if required for >5Gbps capture
sudo apt-get install -y pfring-drivers-zc-dkms

# 6. Clean and refresh package cache
sudo apt-get clean all
sudo apt-get update

# 7. If any driver DKMS modules failed to compile, remove them
sudo apt remove --purge -y pfring-drivers-zc-dkms e1000e-zc-dkms ixgbe-zc-dkms i40e-zc-dkms igb-zc-dkms
sudo apt autoremove -y

# 8. Install final working stack (recommended stable combo)
sudo apt install -y pfring ntopng redis-server

# 9. Enable and start services
sudo systemctl enable --now redis-server ntopng

# 10. Verify ntopng service
sudo systemctl status ntopng --no-pager
sudo ss -tuln | grep 3000
