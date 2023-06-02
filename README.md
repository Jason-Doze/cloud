# Cloud
Cloud is a set of scripts designed to streamline the management of AWS resources via a Raspberry Pi 400 running Ubuntu server. These scripts automate the process of connecting to a Raspberry Pi, installing local dependencies to copy the necessary scripts on it, and simplifying AWS CLI installations and AWS SSO configuration. The scripts also create and terminate AWS EC2 instances to easily provision and deprovision computing resources as needed.

## Structure
1. `pi_local.sh`: A shell script for remote connection, file management, and dependency installation on the Raspberry Pi. The script establishes a connection with the Pi, synchronizes the local directory to the Pi, and triggers AWS related shell scripts (`aws_install.sh`, `aws_login.sh`, and `aws_deploy.sh`).

2. `aws_install.sh`: A script that ensures the Raspberry Pi is ready to interact with AWS resources by installing the AWS CLI. It checks and installs `unzip`, downloads `awscliv2.zip` (if not already downloaded), unzips it, and installs the AWS CLI.

3. `aws_login.sh`: This script facilitates the process of configuring and logging into AWS SSO (Single Sign-On). If you're not authenticated, it initiates the login process.

4. `aws_deploy.sh`: This script manages the setup and deployment of an AWS EC2 instance. It creates an SSH key pair, updates or creates the key in the AWS Secrets Manager, configures a security group for SSH and HTTP access, and finally launches an EC2 instance. Once the instance is up and running, the script establishes an SSH connection to the instance.

5. `aws_destroy.sh`: This script removes deployed AWS resources. It's designed to clean up and remove AWS resources that were deployed using `aws_deploy.sh`.

## Prerequisites
* Raspberry Pi 400 running Ubuntu server.
* SSH service enabled on your Raspberry Pi.
* An AWS account with necessary privileges to create and manage EC2 instances, security groups, secrets, and AWS SSO enabled.
* An authenticator app to generate MFA codes.
* Your unique AWS SSO URL. Each organization is provided with a unique URL for AWS SSO. You'll need this URL to log in. It should look something like this: https://d-xxxxxxxx.awsapps.com/start. Replace this example with your actual AWS SSO URL when you're prompted to log in.


## Usage
1. Set the PI_HOST variable to the IP address of your Raspberry Pi and run the pi_local.sh script:

```bash
PI_HOST=$(dig +short pi | tail -n1) bash pi_local.sh
```

This will initiate AWS CLI installation, login, and EC2 deployment.

2. To view your AWS dashboard, login to your unique AWS SSO URL:
 https://d-xxxxxxxx.awsapps.com/start.

3. After you're done with the AWS instance, type `exit` to leave the instance shell.

4. To login into your Pi Server, navigate to the cloud directory and execute the `aws_destroy.sh` script, run this command:

```bash
PI_HOST=$(dig +short pi | tail -n1); ssh -t -o StrictHostKeyChecking=no $USER@$PI_HOST 'cd cloud; bash aws_destroy.sh; exec $SHELL'

```

5. Confirm that the AWS EC2 instance, associated key pairs, RSA key pair, security group, and secrets created in the AWS Secrets Manager during the deployment process are deleted. You can verify this by checking the AWS EC2 dashboard, key pair listings, security group listings, and the AWS Secrets Manager console.