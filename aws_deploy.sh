# This script manages the setup and deployment of an AWS EC2 instance. It creates an SSH key pair if it doesn't already exist, updates or creates the key in the AWS Secrets Manager, configures a security group for SSH and HTTP access, and finally launches an EC2 instance if it doesn't already exist. Once the instance is up and running, the script establishes an SSH connection to the instance.

# Disable AWS CLI pager
aws configure set cli_pager ""

# Create SSH key pair
if ( aws ec2 describe-key-pairs --profile default --key-name aws_rsa_key )
then
  echo -e "\n==== SSH key pair present ====\n"
else
  echo -e "\n==== Creating SSH key pair ====\n"
  aws ec2 create-key-pair --profile default --key-name aws_rsa_key --query 'KeyMaterial' --output text > aws_rsa_key.pem && chmod 0600 aws_rsa_key.pem 
fi

# Update / Create the SSH key in Secrets Manager
if ( aws secretsmanager get-secret-value --profile default --secret-id rsa_secret_id --query 'SecretString' ) 
then 
  echo -e "\n==== Updating key pair in secrets manager ====\n"
  aws secretsmanager update-secret --profile default --secret-id rsa_secret_id --secret-string "$(cat aws_rsa_key.pem)" --description "SSH for aws log in"
else
  echo -e "\n==== Added key pair to secrets manager ====\n"
  aws secretsmanager create-secret --profile default --name rsa_secret_id --secret-string "$(cat aws_rsa_key.pem)" --description "SSH for aws log in"
fi

# Create the security group, add a rule to the security group to allow SSH and HTTP access from anywhere  
if ( aws ec2 describe-security-groups --profile default --group-name ssh_http --output text)
then
  echo -e "\n==== Security group present ====\n"
else 
  echo -e "\n====  Creating security group ====\n"
  aws ec2 create-security-group --profile default --group-name ssh_http --description "Allow SSH and HTTP" --output text
  aws ec2 authorize-security-group-ingress --profile default --group-id $(aws ec2 describe-security-groups --profile default --group-name ssh_http --query 'SecurityGroups[*].[GroupId]' --output text) --protocol tcp --port 22 --cidr 0.0.0.0/0
  aws ec2 authorize-security-group-ingress --profile default --group-id $(aws ec2 describe-security-groups --profile default --group-name ssh_http --query 'SecurityGroups[*].[GroupId]' --output text) --protocol tcp --port 80 --cidr 0.0.0.0/0
fi

# Create an EC2 instance
if [ $(aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'length(Reservations[])>`0`' --output text) = 'True' ]
then
  echo -e "\n==== EC2 instance created ====\n"
else
  echo -e "\n==== Creating EC2 instance  ====\n"
  aws ec2 run-instances --profile default --image-id ami-06878d265978313ca --instance-type t2.micro --security-group-ids $(aws ec2 describe-security-groups --profile default --group-name ssh_http --query 'SecurityGroups[*].[GroupId]' --output text) --count 1 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value="aws-instance-01"}]' --key-name aws_rsa_key --associate-public-ip-address
fi

echo -e "\n==== Wait for EC2 instance running ====\n"
aws ec2 wait instance-running --profile default --instance-ids $(aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'Reservations[*].Instances[*].InstanceId' --output text) 
echo -e "\n==== EC2 instance running ====\n"

# Connect to instance via SSH
echo -e "\n==== SSH into instance ====\n"
ssh -o StrictHostKeyChecking=no -i ./aws_rsa_key.pem ubuntu@$(aws ec2 describe-instances --profile default --filter Name=tag:Name,Values="aws-instance-01" 'Name=instance-state-name,Values=[running, stopped, pending]' --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)