# Brunner AG – OpenTofu (AWS us-east-1)

## Important
This project creates **the whole network and two EC2 instances**, not just two instances. If you already created VPC-Brunner manually in the AWS Console, **do not run `tofu apply` without planning first**: it will create another VPC with the same name tag, because OpenTofu does not automatically adopt existing resources. Either delete the manually created practice setup, use a clean AWS Lab, or import all existing resources into the OpenTofu state (`tofu import` with exact resource IDs). Never delete resources that other users depend on.

The two cloud-init files include a functional example SSH user `brunner` with your public key, and SSH hardening. If your assignment requires your **personal** cloud-init template, merge its settings into BOTH files, preserving the original `users`, `write_files`, SSH rules and other relevant entries. `write_files`, `packages`, `runcmd` must each appear only once per YAML file. Values of `${ssh_public_key}` must be kept if using this example's key injection. No SSH private key is stored in the project.

## 1. Requirements
- OpenTofu installed: https://opentofu.org/docs/intro/install/
- AWS CLI configured and AWS permissions for VPC, EC2, EIP, NAT Gateway and SSM reads.
- Access to `us-east-1`, AZ `us-east-1a` (in some Lab accounts this AZ label may differ).
- Your SSH public key in OpenSSH format. Windows PowerShell example: `Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub` (adjust to actual key file).

Check:
```powershell
tofu version
aws sts get-caller-identity
```
If using an AWS Academy/Learner Lab: click **Start Lab**, copy its **temporary** AWS credentials into your AWS CLI profile or set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` in the local shell. They expire. Do not commit credentials to git. Your Lab might prohibit creating a NAT Gateway or allocating EIPs; record the restriction for the assignment.

## 2. Setup
1. Extract the ZIP and open a terminal in the `Brunner-OpenTofu` folder.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`.
3. Replace `ssh_public_key` with the full contents of YOUR `.pub` file. Do not paste your private key.
4. If needed, edit the 2 cloud-init templates to match your existing personal SSH/user setup.
5. Check that no duplicate manually created Brunner resources will be unintentionally created.

## 3. Run
```powershell
tofu init
tofu fmt -recursive
tofu validate
tofu plan -out=brunner.tfplan
tofu apply brunner.tfplan
tofu output
```
Wait for EC2 cloud-init to finish as necessary; AWS reporting the instance as running is not proof that apt finished. OpenTofu ensures the DB NAT route exists **before instance creation**, but installation still depends on network access/repository availability.

## 4. Test
Get web Elastic IP with `tofu output -raw web_elastic_ip`.
- Browser: `http://WEB_EIP` (Apache default page).
- SSH to web: `ssh -i PATH_TO_PRIVATE_KEY brunner@WEB_EIP` (same key as the supplied public key).
- On Web: `sudo cloud-init status --wait` and `systemctl is-active apache2`.
- On Web: `sudo apt-get update && sudo apt-get install -y netcat-openbsd` (only if not installed).
- On Web: `nc -vz -w 5 10.0.11.20 3306` (database port), `nc -vz -w 5 10.0.11.20 22` (SSH port).
- A successful TCP connection on 3306 proves network/port access, **not** that a MariaDB login is ready. MariaDB users and grants require additional database configuration.
- Brunner-DB must have NO public IP, and `SG-DB` inbound should reference `SG-Web` (not `0.0.0.0/0`).
- For issues on Web: `sudo tail -n 100 /var/log/cloud-init-output.log`.
- The web server has no database application preinstalled; only Apache is configured.

## 5. Screenshots / submission
In AWS console capture VPC and CIDR, both subnets/AZ, both route tables and default routes/associations, both security groups and sources, both EC2 private IPs and public EIP for web, and the NAT gateway.

## 6. Change or destroy
`user_data_replace_on_change = true` means updating a cloud-init template REPLACES the respective EC2 instance when `tofu apply` is run again. An EIP may briefly detach and reattach. Always inspect `tofu plan` before applying changes.

Clean up when done:
```powershell
tofu destroy
```
Review the plan and confirm. AWS resources (especially NAT Gateway, EC2 and Elastic IP/public IPv4) can incur ongoing charges while running.

## Reference docs
- https://opentofu.org/docs/intro/install/
- https://ubuntu.com/aws/docs/aws-how-to/instances/find-ubuntu-images/
- https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
