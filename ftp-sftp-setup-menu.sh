#!/bin/bash
# ftp-sftp-setup-menu.sh
# Interactive FTP/SFTP server setup and management script
# Usage: sudo bash ftp-sftp-setup-menu.sh

set -euo pipefail

# Color codes
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

# Function to pause for user input
pause() {
    read -rp "Press Enter to continue..."
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ----------------------------
# FTP Functions
# ----------------------------

install_ftp() {
    echo -e "${GREEN}Installing and setting up FTP server...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install vsftpd -y

    echo -e "${GREEN}Backing up existing vsftpd.conf...${NC}"
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak || true

    sudo bash -c 'cat > /etc/vsftpd.conf <<EOL
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
EOL'

    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd

    read -rp "Enter FTP username: " ftpuser
    if id "$ftpuser" &>/dev/null; then
        echo -e "${YELLOW}User $ftpuser already exists! Skipping creation.${NC}"
    else
        sudo adduser "$ftpuser"
    fi

    sudo mkdir -p /home/"$ftpuser"/ftp
    sudo chown "$ftpuser":"$ftpuser" /home/"$ftpuser"/ftp
    sudo chmod 750 /home/"$ftpuser"/ftp

    echo -e "${GREEN}Configuring firewall for FTP...${NC}"
    sudo ufw allow 21/tcp
    sudo ufw allow 40000:50000/tcp
    sudo ufw reload

    echo -e "${GREEN}FTP setup complete!${NC}"
    echo "Connect via: ftp $ftpuser@<server-ip> or lftp $ftpuser@<server-ip>"
    pause
}

# ----------------------------
# SFTP Functions
# ----------------------------

install_sftp() {
    echo -e "${GREEN}Setting up SFTP server...${NC}"
    # OpenSSH should already be installed on Ubuntu
    sudo apt update && sudo apt install openssh-server -y
    sudo systemctl enable ssh
    sudo systemctl start ssh

    read -rp "Enter SFTP username: " sftpuser
    if id "$sftpuser" &>/dev/null; then
        echo -e "${YELLOW}User $sftpuser already exists! Skipping creation.${NC}"
    else
        sudo adduser "$sftpuser"
    fi

    sudo mkdir -p /home/"$sftpuser"/sftp
    sudo chown root:root /home/"$sftpuser"
    sudo chmod 755 /home/"$sftpuser"
    sudo chown "$sftpuser":"$sftpuser" /home/"$sftpuser"/sftp

    # Configure SSHD for SFTP
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak || true
    if ! grep -q "Match User $sftpuser" /etc/ssh/sshd_config; then
        sudo bash -c "cat >> /etc/ssh/sshd_config <<EOL

# SFTP configuration for $sftpuser
Match User $sftpuser
    ChrootDirectory /home/$sftpuser
    ForceCommand internal-sftp
    AllowTcpForwarding no
EOL"
    fi

    sudo systemctl restart ssh

    echo -e "${GREEN}SFTP setup complete!${NC}"
    echo "Connect via: sftp $sftpuser@<server-ip>"
    pause
}

# ----------------------------
# Other Management Functions
# ----------------------------

start_ftp() {
    sudo systemctl start vsftpd
    sudo systemctl enable vsftpd
    echo -e "${GREEN}FTP server started.${NC}"
    pause
}

stop_ftp() {
    sudo systemctl stop vsftpd
    echo -e "${RED}FTP server stopped.${NC}"
    pause
}

uninstall_ftp() {
    sudo systemctl stop vsftpd
    sudo apt remove --purge vsftpd -y
    echo -e "${RED}FTP server removed.${NC}"
    pause
}

firewall_status() {
    sudo ufw status
    pause
}

# ----------------------------
# Menu
# ----------------------------
show_menu() {
    clear
    echo -e "${GREEN}===== FTP/SFTP Server Management Menu =====${NC}"
    echo "1) Install and setup FTP server"
    echo "2) Install and setup SFTP server"
    echo "3) Start FTP server"
    echo "4) Stop FTP server"
    echo "5) Uninstall FTP server"
    echo "6) Check firewall status"
    echo "7) Exit"
    echo -n "Enter your choice [1-7]: "
}

# Main loop
while true; do
    show_menu
    read -r choice
    case $choice in
        1) install_ftp ;;
        2) install_sftp ;;
        3) start_ftp ;;
        4) stop_ftp ;;
        5) uninstall_ftp ;;
        6) firewall_status ;;
        7) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid choice!${NC}"; pause ;;
    esac
done
