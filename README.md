# Setting-up-a-ftp-server

Learning and wanting to know more about networking, file transferring over the internet, I stumbled upon a **File-Transfer-Protocol** (FTP). I configured
 a server, from which i could share and access files over the internet. This project was made to learn more about servers, firewalls, protocols, ports and how we access them, how we connect to devices over the internet and so on...... 

These were the steps I used to set up and establish a simple ftp server.

I used Ubuntu 24.04 

1. Introduction
File Transfer Protocol (FTP) is a standard network protocol used to transfer files between a client and a server. This report outlines the complete setup process for an FTP server on Ubuntu 24.04, along with configuration steps, testing, and troubleshooting.
 
2. Prerequisites
Before setting up the FTP server, ensure you have:

•	A system running Ubuntu 24.04 (GUI or CLI).
•	Sudo/root access.
•	A stable network connection.

3. Installing vsftpd (Very Secure FTP Daemon)
vsftpd is a widely used FTP server for Unix-based systems.
3.1 Updating System Package, installing vsftpd and enabling
```   
  sudo apt update && sudo apt upgrade -y
  sudo apt install vsftpd -y
  sudo systemctl start vsftpd
  sudo systemctl enable vsftpd
```

To verify the service status:
```
  sudo systemctl status vsftpd
```

4. Configuring vsftpd
To ensure proper security and functionality, modify the vsftpd configuration file.
4.1 Open vsftpd Configuration File
```
sudo nano /etc/vsftpd.conf
```
4.2 Modify/Add These Settings
```
  anonymous_enable=NO      # Disable anonymous access
  local_enable=YES         # Allow local users to log in
  write_enable=YES         # Enable write permissions
  chroot_local_user=YES    # Restrict users to home directories
  allow_writeable_chroot=YES
  pasv_enable=YES          # Enable Passive Mode
  pasv_min_port=40000
  pasv_max_port=50000
  Save and exit (CTRL + X, then Y, then Enter).
```
4.3 Restart vsftpd Service
```
  sudo systemctl restart vsftpd
```

5. Creating an FTP User
To allow authenticated FTP access, create a dedicated user.

5.1 Create a New FTP User
```
  sudo adduser ftpuser
```
Follow the prompts to set a password.
5.2 Assign Permissions
```
  sudo mkdir -p /home/ftpuser/ftp
  sudo chown ftpuser:ftpuser /home/ftpuser/ftp
  sudo chmod 750 /home/ftpuser/ftp
```

6. Configuring Firewall for FTP
If UFW (Uncomplicated Firewall) is enabled, allow FTP traffic.
6.1 Allow FTP Ports
```
  sudo ufw allow 21/tcp
  sudo ufw allow 40000:50000/tcp
  sudo ufw reload  
```
6.2 Verify Firewall Status
```
  sudo ufw status
```

7. Finding the Server IP Address
To connect to the FTP server, find the server's IP address.
7.1 Check Local IP Address
```
  ip a
```
7.2 Check Public IP Address
```
	curl ifconfig.me
```

8. Testing the FTP Server
Once the server is configured, test it using a client machine.
8.1 From Ubuntu or macOS Terminal
```   
	ftp <ip address of your server>
```
Here we have in step 4 we have altered the vsftpd.conf file to enable pasv mode. Since that is enabled we can only access the data with no writing availiblity
If we want to have writing avaliblity, Connect using:
```
  lftp username@ip_address
```
Enter the username and password when prompted.
8.2 FTP Commands to Verify Connection
```
  ls       # List files
  pwd      # Show current directory
  put file.txt   # Upload file
  get file.txt   # Download file
  bye      # Exit FTP
```
8.3 Access via File Manager (GUI)
•	Ubuntu/macOS: Open Files (Nautilus) → Ctrl + L → enter ftp://ip_address.
•	Windows: Open File Explorer → type ftp://ip_address in the address bar.
 
9. Stopping or Disabling the FTP Server
If you need to stop or disable the FTP service:
9.1 Stop FTP Server (Temporary)
```   
	sudo systemctl stop vsftpd
```
9.2 Disable FTP on Startup (Permanent)
```
  sudo systemctl disable vsftpd
```
9.3 Uninstall vsftpd (If No Longer Needed)
```
  sudo apt remove vsftpd -y
  sudo apt purge vsftpd -y
``` 

Additional Security (SFTP Recommended)
SFTP (FTP over SSH) is a more secure alternative. Use it instead of FTP:
	sftp ftpuser@ip_address
This method encrypts file transfers, improving security significantly.
 

During errors or any trouble connecting to the server, we can see the **log** maintained by the vsftpd. 
```
  sudo nano /etc/vsftpd.co
```
 
Conclusion
This report outlines the complete process of setting up a FTP server on Ubuntu 24.04, from installation to configuration, testing, and troubleshooting. The FTP server allows secure file transfer within a local network. To enhance security, consider SFTP (Secure FTP) instead of FTP.
 
This project helped me understand the working of ports, protocols and little about firewalls. 
I have limited this to file transfer within a local network. 
To make it accessible globally/remotely from another network, we have to use few methods such as port forwarding, vpn tunneling etc which could expose our server to the world. If not configured properly, might lead to unnessesary attention from the internet. 
This project was made out of boredom and wanting to learn more about networking and servers.

References
•	Official vsftpd Documentation: https://security.appspot.com/vsftpd.html
•	Ubuntu FTP Guide: https://help.ubuntu.com/community/vsftpd

