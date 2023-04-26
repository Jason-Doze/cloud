#!/bin/bash

# This script prompts the user to configure the SSO sign-in and login in process.
aws configure sso

# Authenticate with AWS SSO
if ( aws sts get-caller-identity ) 
then
  echo -e "\n==== SSO authenticated ====\n"
else 
  echo -e "\n==== Authenticating SSO ====\n"
  aws sso login 
fi