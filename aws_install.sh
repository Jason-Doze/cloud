#!/bin/bash

# This script installs the AWS CLI and prompts the SSO sign in process.

sudo apt update

# Install unzip
if ( which unzip > /dev/null )
then
  echo -e "\n==== Unzip present ====\n"
else 
  echo -e "\n==== Installing unzip ====\n"
  sudo apt install unzip
fi

# Install AWS CLI 
if [ -f awscliv2.zip ]
then
  echo -e "\n==== awscliv2.zip currently downloaded ====\n"
else 
  echo -e "\n==== Downloading awscliv2.zip ====\n"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
fi

if [ -f aws/install ]
then
  echo -e "\n==== awscliv2.zip unzipped ====\n"
else 
  echo -e "\n==== Unzipping awscliv2.zip ====\n"
  unzip -o awscliv2.zip
fi

if ( which aws > /dev/null ) 
then
  echo -e "\n==== Awscli currently installed ====\n"
else 
  echo -e "\n==== Installing awscli ====\n"
  sudo ./aws/install
fi

# Authenticate and sign in with AWS SSO
if ( aws sts get-caller-identity ) 
then
  echo -e "\n==== SSO authenticated ====\n"
else 
  echo -e "\n==== Authenticating SSO ====\n"
  aws configure sso --profile default
fi