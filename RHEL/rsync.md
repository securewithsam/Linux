**Use case**:  
* Create a new user called rsync on RHEL 8   
* Set up SSH key-based login between the source and destination machines via port 2222   
* Grant sudo rights for 'rsync' user   
* Install rsync   
* Configure rsync using the newly created rsync user to sync data from 10.10.10.1  to  172.16.16.2 for the paths below on both identical machines and same paths for both servers   
```sh
/root
/var/lib/docker/volumes/kcm_common-storage/_data/recordings  
/etc/kcm-setup/
```

### Step 1: Create a New User Called `rsync` on Both Servers with SSH Key-Based Login and No Password

**Perform these steps on both the source machine (10.10.10.1) and the destination machine (172.16.16.2):**

1. **Create the `rsync` user**:
    ```bash
    sudo useradd rsync
    ```

2. **Create an SSH key pair for the `rsync` user**:
    ```bash
    sudo mkdir -p /home/rsync/.ssh
    sudo ssh-keygen -t rsa -b 4096 -f /home/rsync/.ssh/id_rsa -N ""
    ```

3. **Set proper permissions**:
    ```bash
    sudo chown -R rsync:rsync /home/rsync/.ssh
    sudo chmod 700 /home/rsync/.ssh
    sudo chmod 600 /home/rsync/.ssh/id_rsa
    sudo chmod 644 /home/rsync/.ssh/id_rsa.pub
    ```

4. **Add the public key to the `authorized_keys` file**:
    ```bash
    sudo cp /home/rsync/.ssh/id_rsa.pub /home/rsync/.ssh/authorized_keys
    sudo chmod 600 /home/rsync/.ssh/authorized_keys
    ```

5. **Disable password authentication for the `rsync` user**:
    Edit the SSH configuration file:
    ```bash
    sudo nano /etc/ssh/sshd_config
    ```

    Add the following lines:
    ```bash
    Match User rsync
        PasswordAuthentication no
    ```

6. **Restart SSH service**:
    ```bash
    sudo systemctl restart sshd
    ```

### Step 2: Set Up SSH Key-Based Login Between the Source and Destination Machines

**Perform this step on the source machine (10.10.10.1):**

1. **Copy the `rsync` user’s SSH key from the source machine to the destination machine**:
    ```bash
    sudo ssh-copy-id -i /home/rsync/.ssh/id_rsa.pub -p 2022 rsync@172.16.16.2
    ```

### Step 3: Grant Sudo Rights

**Perform this step on both the source machine (10.10.10.1) and the destination machine (172.16.16.2):**

1. **Edit the sudoers file**:
    ```bash
    sudo visudo
    ```

2. **Add the following line to grant sudo privileges to the `rsync` user**:
    ```bash
    rsync ALL=(ALL) NOPASSWD:ALL
    ```

### Step 4: Install `rsync`

**Perform this step on both the source machine (10.10.10.1) and the destination machine (172.16.16.2):**

1. **Install `rsync`**:
    ```bash
    sudo dnf install -y rsync
    ```

### Step 5: Configure `rsync` Using the Newly Created `rsync` User to Sync Data

**Perform these steps on the source machine (10.10.10.1):**

1. **Create an `rsync` script**:
    ```bash
    sudo nano /home/rsync/rsync_backup.sh
    ```

2. **Add the following lines to the script**:
    ```bash
    #!/bin/bash

    RSYNC_USER="rsync"
    DESTINATION="rsync@172.16.16.2"
    SOURCE_PATHS=("/var/lib/docker/volumes/kcm_common-storage/_data/recordings" "/etc/kcm-setup/")
    DESTINATION_PATHS=("/var/lib/docker/volumes/kcm_common-storage/_data/recordings" "/etc/kcm-setup/")

    for i in ${!SOURCE_PATHS[@]}; do
        rsync -avz -e "ssh -p 2022" ${SOURCE_PATHS[$i]} $DESTINATION:${DESTINATION_PATHS[$i]}
    done
    ```

3. **Make the script executable**:
    ```bash
    sudo chmod +x /home/rsync/rsync_backup.sh
    ```

**Perform these steps on the destination machine (172.16.16.2):**

1. **Ensure the directories exist and have appropriate permissions**:
    ```bash
    sudo mkdir -p /var/lib/docker/volumes/kcm_common-storage/_data/recordings
    sudo mkdir -p /etc/kcm-setup/
    sudo chown -R rsync:rsync /var/lib/docker/volumes/kcm_common-storage/_data/recordings
    sudo chown -R rsync:rsync /etc/kcm-setup/
    ```

### Step 6: Test and Automate the `rsync` Script

**Perform these steps on the source machine (10.10.10.1):**

1. **Test the `rsync` script**:
    ```bash
    sudo /home/rsync/rsync_backup.sh
    ```

2. **Set up a cron job to automate the `rsync`**:
    ```bash
    sudo crontab -e -u rsync
    ```

3. **Add the following line to run the script every day at 2 AM**:
    ```bash
    0 2 * * * /home/rsync/rsync_backup.sh
    ```

This completes the setup for the `rsync` user with SSH key-based login, sudo rights, and an `rsync` configuration to sync data between the two servers using port 2022.
