#!/bin/bash

# This script installs and configures the required command-line utilities, creates EC2 instances with the specified Amazon Machine Image (AMI) ID, ports, security group, and connects to the instance via Secure Shell (SSH). Additionally, it also stores the RSA key in AWS Secrets Manager for secure management.

# Install aws cli
if ( which aws > /dev/null ) 
then
  echo -e "\n==== Awscli currently installed ====\n"
else 
  echo -e "\n==== Installing awscli ====\n"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# 
if ( aws sts get-caller-identity ) 
then
  echo -e "\n==== SSO authenticated ====\n"
else 
  echo -e "\n==== Authenticating SSO ====\n"
  aws sso login --profile default
fi

