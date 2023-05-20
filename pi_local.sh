#!/bin/bash

# This script connects to a Raspberry Pi 400 running Ubuntu Server and synchronizes the local directory with the Pi. It then installs the AWS CLI on the Pi and initiates an SSH session to facilitate AWS SSO configuration and login.

echo -e "\n==== Validate Pi server is running ====\n"
while true
do
  if ( ssh -T -o StrictHostKeyChecking=no "$USER@$PI_HOST" 'exit' )
  then
    echo -e "\n==== Server is running  ====\n"
    break
  else
    printf "\033[31m.\033[0m"
    sleep 5
  fi
done

# Use rsync to copy files to the Pi server
echo -e "\n==== Copying files to Pi ====\n"
rsync -av -e "ssh -o StrictHostKeyChecking=no" --delete --exclude={'.git','.gitignore','commands.txt','README.md'} "$(pwd)" "$USER"@$PI_HOST:/home/"$USER"

# Use SSH to execute commands on the Pi server
echo -e "\n==== Executing aws_install script ====\n"
ssh -t -o StrictHostKeyChecking=no $USER@$PI_HOST 'cd cloud && bash aws_install.sh'

# SSH into Pi server
echo -e "\n==== SSH into Pi ====\n"
ssh -t -o StrictHostKeyChecking=no $USER@$PI_HOST 'cd cloud && bash aws_login.sh'
