#!/bin/bash

# This script connects to a Raspberry Pi 400 running Ubuntu Server and synchronizes the local directory with the Pi. It then installs the AWS CLI on the Pi, facilitates AWS SSO configuration / login, and then sets up and deploys an AWS EC2 instance.

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

# Install Homebrew
if ( which brew > /dev/null ) 
then
  echo -e "\n==== Brew installed ====\n"
else 
  echo -e "\n==== Installing brew ====\n"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Rsync
if ( which rsync )
then
  echo -e "\n==== Rsync is present ====\n"
else
  echo -e "\n==== Installing Rsync ====\n"
  brew install rsync
fi

# Use rsync to copy files to the Pi server
echo -e "\n==== Copying files to Pi ====\n"
rsync -av -e "ssh -o StrictHostKeyChecking=no" --delete --exclude={'.git','.gitignore','commands.txt','README.md','pi_local.sh'} $(pwd) $USER@$PI_HOST:/home/$USER

# Use SSH to execute commands on the Pi server
echo -e "\n==== Executing aws_install script ====\n"
ssh -t -o StrictHostKeyChecking=no $USER@$PI_HOST 'cd cloud && bash aws_install.sh && bash aws_deploy.sh'
