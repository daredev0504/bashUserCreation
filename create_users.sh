#!/bin/bash

# Check if running as root
if [[ $UID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define the input file, log file, and secure password file
INPUT_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Check if the input file was provided and exists
if [[ -z "$INPUT_FILE" ]]; then
   echo "No input file provided."
   exit 1
fi
if [[ ! -f "$INPUT_FILE" ]]; then
   echo "File $INPUT_FILE not found."
   exit 1
fi

# Create the log file and password file if they don't exist
touch "$LOG_FILE"
mkdir -p /var/secure
touch "$PASSWORD_FILE"

# Function to generate a random password
generate_password() {
  tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Function to log messages
log_message() {
  echo "$1" | tee -a "$LOG_FILE"
}

log_message "Backing up created files"
# Backup existing files
cp "$PASSWORD_FILE" "${PASSWORD_FILE}.bak"
cp "$LOG_FILE" "${LOG_FILE}.bak"

# Set permissions for password file
chmod 600 "$PASSWORD_FILE"

# Read the input file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
   # Ignore whitespace
  line=$(echo "$line" | xargs)
  echo "Processing line: $line"
  
  # Skip empty lines and comments
  [ -z "$line" ] && continue
  
  # Parse the username and groups
  USERNAME=$(echo "$line" | cut -d';' -f1 | xargs)
  GROUPS=$(echo "$line" | cut -d';' -f2 | xargs| tr -d ' ')

  echo "Username: $USERNAME"
  echo "Extracted groups: $GROUPS"

  # Create the user and their personal group if they don't exist
  if id "$USERNAME" &>/dev/null; then
      log_message "User $USERNAME already exists. Skipping..."
  else
      # Create personal group for the user
      groupadd "$USERNAME"
      # Create user with their personal group
      useradd -m -s /bin/bash -g "$USERNAME" "$USERNAME"
      if [ $? -eq 0 ]; then
          log_message "User $USERNAME created with home directory."
      else
          log_message "Failed to create user $USERNAME."
          continue
      fi
      # Generate a random password and set it for the user
      PASSWORD=$(generate_password)
      echo "$USERNAME:$PASSWORD" | chpasswd
      if [ $? -eq 0 ]; then
          log_message "Password for user $USERNAME set."
      else
          log_message "Failed to set password for user $USERNAME."
      fi
      # Store the password securely
      echo "$USERNAME:$PASSWORD" >> "$PASSWORD_FILE"
      # Set the correct permissions for the home directory
      chmod 700 /home/"$USERNAME"
      chown "$USERNAME":"$USERNAME" /home/"$USERNAME"
      log_message "Home directory permissions set for user $USERNAME."
  fi

  # Add user to additional groups
  if [ -n "$GROUPS" ]; then
      IFS=',' read -r -a GROUP_ARRAY <<< "$GROUPS"
      for GROUP in "${GROUP_ARRAY[@]}"; do
          # Create group if it doesn't exist
          if ! getent group "$GROUP" > /dev/null 2>&1; then
              groupadd "$GROUP"
              log_message "Group $GROUP created."
          fi
          # Add user to the group
          usermod -a -G "$GROUP" "$USERNAME"
          if [ $? -eq 0 ]; then
              log_message "User $USERNAME added to group $GROUP."
          else
              log_message "Failed to add user $USERNAME to group $GROUP."
          fi
      done
  fi
done < "$INPUT_FILE"
log_message "User creation process completed."