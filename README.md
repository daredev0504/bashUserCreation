### README: User Creation Script
---
## Overview
This document provides detailed instructions and explanations for the `create_users.sh` script. This script is designed to automate the process of creating users and groups on a Linux system, set up their home directories with appropriate permissions, generate random passwords for the users, and log all actions. Additionally, it securely stores the generated passwords.
---
## Table of Contents
0. [Join HNG](#JoinHNG)
1. [Purpose](#purpose)
2. [Input File Format](#input-file-format)
3. [Script Functionality](#script-functionality)
4. [Prerequisites](#prerequisites)
5. [Usage Instructions](#usage-instructions)
6. [Security Considerations](#security-considerations)
7. [Logging and Backup](#logging-and-backup)
8. [Error Handling](#error-handling)
9. [Conclusion](#conclusion)
---
## Purpose
The `create_users.sh` script aims to streamline the process of onboarding new developers by automating user and group creation. This ensures consistency, security, and efficiency in managing user accounts.
---
## Input File Format
The input file (`users.txt`) should contain the usernames and groups in the following format:
```plaintext
username; group1,group2,group3
```
### Example
```plaintext
light; www-data,sudo,staff
tosingh; www-data,staff
peter; sudo
```
- Each line represents a user.
- Usernames and user groups are separated by a semicolon (`;`).
- Multiple groups are delimited by a comma (`,`).
- Whitespace around usernames and groups is ignored.
---
## Script Functionality
### Main Steps
1. **Read the Input File:**
  - The script reads each line from the `users.txt` file, ignoring whitespace and empty lines.
2. **Parse the Username and Groups:**
  - Extracts the username and group information from each line.
3. **Create User and Personal Group:**
  - Checks if the user already exists. If not, creates the user and their personal group.
4. **Add User to Additional Groups:**
  - Adds the user to any additional specified groups.
5. **Generate Random Password:**
  - Generates a random 12-character password for the user.
6. **Set Up Home Directory:**
  - Ensures the home directory is created with the correct permissions (`700`) and ownership.
7. **Log Actions:**
  - Logs all actions to `/var/log/user_management.log`.
8. **Store Passwords Securely:**
  - Stores the generated passwords in `/var/secure/user_passwords.txt`.
### Password Generation
The `generate_password` function uses `/dev/urandom` to generate a secure random password.
```bash
generate_password() {
   tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}
```
### Logging
The `log_message` function ensures all actions are logged to both the console and the log file.
```bash
log_message() {
   echo "$1" | tee -a $LOG_FILE
}
```
---
## Prerequisites
- Ensure you have root or sudo privileges to create users and groups.
- The `/var/secure` directory should be created and have restricted permissions.
---
## Usage Instructions
### Step 1: Prepare the Input File
Create a `users.txt` file in the same directory as the script. Ensure it follows the specified format.
### Step 2: Make the Script Executable
```bash
chmod +x create_users.sh
```
### Step 3: Run the Script
Execute the script with root privileges:
```bash
sudo ./create_users.sh
```
---
## Security Considerations
- The `/var/secure` directory should have restricted permissions (`700`) to prevent unauthorized access.
- The `user_passwords.txt` file should have permissions set to `600`.
```bash
chmod 700 /var/secure
chmod 600 /var/secure/user_passwords.txt
```
---
## Logging and Backup
- The script logs all actions to `/var/log/user_management.log`.
- Backups of existing log and password files are created before modifications.
### Log Rotation
Consider setting up log rotation for `/var/log/user_management.log` to prevent the file from growing indefinitely.
---
## Error Handling
- The script checks if the user already exists and skips creation if so.
- It verifies the success of each critical operation (user creation, group addition, password setting) and logs appropriate messages.
- Failures in any step are logged and the script continues to the next user.
---
## Conclusion
The `create_users.sh` script provides a robust and secure way to automate the creation of users and groups, set up home directories, and manage passwords. By following the usage instructions and considering security and logging best practices, you can efficiently manage user onboarding in a Linux environment.
---
## JoinHNG
HNG is a company with a mission — we work with the very best techies to help them enhance their skills through our HNG internship program and build their network. We also work with clients to find them the best technical talent across the globe.
https://hng.tech/premium
https://hng.tech/internship,