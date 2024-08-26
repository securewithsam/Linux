To set up an `rsync` user on RHEL 8, configure SSH key-based login, grant sudo rights, install `rsync`, and configure the data sync between the source and destination machines, follow the steps below:

### Step 1: Create the `rsync` User

1. **Create the user**:
    ```bash
    sudo useradd -m rsync
    ```

2. **Set a password for the user**:
    ```bash
    sudo passwd rsync
    ```

### Step 2: Set Up SSH Key-Based Login

1. **Generate SSH keys** on the source machine (`10.45.90.62`):
    ```bash
    sudo -u rsync ssh-keygen -t rsa -b 4096 -f /home/rsync/.ssh/id_rsa
    ```

2. **Copy the public key to the destination machines**:
    ```bash
    ssh-copy-id -i /home/rsync/.ssh/id_rsa.pub -p 2222 rsync@172.17.10.61
    ssh-copy-id -i /home/rsync/.ssh/id_rsa.pub -p 2222 rsync@10.45.90.73
    ```

3. **Test the SSH connection**:
    ```bash
    ssh -p 2222 rsync@172.17.10.61
    ssh -p 2222 rsync@10.45.90.73
    ```

### Step 3: Grant Sudo Rights to the `rsync` User

1. **Edit the sudoers file**:
    ```bash
    sudo visudo
    ```

2. **Add the following line to grant `rsync` user sudo rights**:
    ```bash
    rsync ALL=(ALL) NOPASSWD: ALL
    ```

### Step 4: Install `rsync` on All Machines

1. **Install `rsync`**:
    ```bash
    sudo yum install rsync -y
    ```

### Step 5: Configure `rsync` for Data Sync

1. **Create the directories on the destination machines if they don't exist**:
    ```bash
    ssh -p 2222 rsync@172.17.10.61 "sudo mkdir -p /root /var/lib/docker/volumes/kcm_common-storage/_data/recordings /etc/kcm-setup/"
    ssh -p 2222 rsync@10.45.90.73 "sudo mkdir -p /root /var/lib/docker/volumes/kcm_common-storage/_data/recordings /etc/kcm-setup/"
    ```

2. **Sync the directories from the source machine to the destination machines**:

    For 172.17.10.61:
    ```bash
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /root rsync@172.17.10.61:/root
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /var/lib/docker/volumes/kcm_common-storage/_data/recordings rsync@172.17.10.61:/var/lib/docker/volumes/kcm_common-storage/_data/recordings
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /etc/kcm-setup/ rsync@172.17.10.61:/etc/kcm-setup/
    ```

    For 10.45.90.73:
    ```bash
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /root rsync@10.45.90.73:/root
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /var/lib/docker/volumes/kcm_common-storage/_data/recordings rsync@10.45.90.73:/var/lib/docker/volumes/kcm_common-storage/_data/recordings
    sudo -u rsync rsync -avz -e 'ssh -p 2222' /etc/kcm-setup/ rsync@10.45.90.73:/etc/kcm-setup/
    ```

This setup will allow you to use the `rsync` user to sync data securely between the source and destination machines.
