#!/bin/bash

# This script deletes the IP fingerprint from AWS in known hosts, terminates EC2 instances, deletes AWS key pairs, the RSA key pair, the RSA key pair in AWS Secrets Manager, and security groups created in the aws_deploy script. 


# Delete IP fingerprint from AWS to known_hosts
ssh-keygen -F "~/.ssh/known_hosts" -R $( aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'Reservations[*].Instances[*].PublicIpAddress' --output text ) 
echo -e "\n==== Deleted host from known host ====\n"


# Terminate the EC2 instance
if [ $( aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'length(Reservations[])>`0`' --output text) = 'True' ]
then
  echo -e "\n==== Terminating EC2 instance ====\n"
  aws ec2 terminate-instances --profile default --instance-ids $( aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'Reservations[*].Instances[*].InstanceId' --output text ) 
else
  echo -e "\n==== No EC2 instance present ====\n"
fi
  
# Delete the AWS key pair
if ( aws ec2 describe-key-pairs --profile default --key-name aws_rsa_key --output text)
then
  echo -e "\n==== Deleting AWS RSA key pair ====\n"
  aws ec2 delete-key-pair --profile default --key-name aws_rsa_key 
else
  echo -e "\n==== No AWS RSA key pair present ====\n"
fi

# Delete the RSA key pair file
if [ -f ./aws_rsa_key.pem ]
then 
  echo -e "\n==== Deleting the RSA key pair file ====\n"
  rm -f ./aws_rsa_key.pem
else 
  echo -e "\n==== No RSA key pair file present ====\n"
fi

# Delete the security group
if ( aws ec2 describe-security-groups --profile default --group-names ssh_http --output text )
then
  echo -e "\n==== Deleting security group ====\n"
  aws ec2 wait instance-terminated --profile default --instance-ids $( aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'Reservations[*].Instances[*].InstanceId' --output text ) 
  aws ec2 delete-security-group --profile default --group-name ssh_http --output text
else
  echo -e "\n==== No security group present ====\n"
fi

aws sso logout --profile default && aws configure list