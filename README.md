# Cloud
Cloud is a set of scripts designed to streamline the management of AWS resources via a Raspberry Pi 400 running Ubuntu server. These scripts automate the process of connecting to your Raspberry Pi, copying and executing necessary scripts on it, and simplifying your AWS CLI installations and AWS SSO configuration.

## Structure
1. `pi_local.sh`: A shell script for remote connection and file management on the Raspberry Pi. It waits until it can establish a connection with the Pi, synchronizes the local directory to the Pi, and triggers AWS related shell scripts (`aws_install.sh` and `aws_login.sh`).

2. `aws_install.sh`: A script that ensures your Raspberry Pi is ready to interact with AWS resources by installing the AWS CLI. It checks and installs `unzip`, downloads `awscliv2.zip` (if not already downloaded), unzips it, and installs the AWS CLI.

3. `aws_login.sh`: This script facilitates the process of configuring and logging into AWS SSO (Single Sign-On). If you're not authenticated, it initiates the login process.

## Prerequisites
* Raspberry Pi 400 running Ubuntu server.
* SSH service enabled on your Raspberry Pi.
* An AWS account with AWS SSO enabled.
* An authenticator app to generate MFA codes.
* Your unique AWS SSO URL. Each organization is provided with a unique URL for AWS SSO. You'll need this URL to log in. It should look something like this: https://d-xxxxxxxx.awsapps.com/start. Replace this example with your actual AWS SSO URL when you're prompted to log in.


## Usage
To run these scripts, execute the following command:

```bash
PI_HOST=$(dig +short pi | tail -n1) bash pi_local.sh
```
This command sets the PI_HOST variable to the IP address of your Raspberry Pi and then runs the `pi_local.sh` script.



