# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

### Step 1: Build the Packer Image

Run the following command:

packer build server.json

Note: The Packer build could not complete due to network security restrictions blocking SSH access in the lab environment.

### Step 2: Deploy Infrastructure with Terraform

Initialize Terraform:

terraform init

Validate configuration:

terraform validate

Create a plan file:

terraform plan -out solution.plan

Apply the configuration:

terraform apply


### Step 3: Verify Deployment

Run:

terraform show solution.plan

This confirms that the infrastructure matches the configuration.

##  Customization

The Terraform deployment can be customized by modifying the variables defined in the `variables.tf` and `terraform.tfvars` files.

Examples of customizable parameters include:

- **resource_group_name**  
  Change the resource group where infrastructure will be deployed.

- **vm_name_prefix**  
  Modify the name of the virtual machine.

- **vm_size**  
  Change the VM size (e.g., Standard_B1s → Standard_B2s).

- **vm_count**  
  Increase or decrease the number of virtual machines.

- **network settings**  
  Update VNet and subnet address ranges in `main.tf`.

To apply changes:

1. Update values in `terraform.tfvars`
2. Run:
   ```bash
   terraform plan
   terraform apply

### Output

The Terraform deployment creates the following resources:

- Virtual Network (my-vnet)
- Subnet (my-subnet)
- Network Security Group (my-nsg)
- Network Interface (my-nic)
- Virtual Machine (my-vm)
- Public IP (my-pip)
- Load Balancer (my-lb)

After running terraform apply, the expected output is:

Apply complete! Resources: X added, 0 changed, 0 destroyed.

The result is a secure Azure environment where the virtual machine is not directly accessible from the internet and traffic is managed through the load balancer.


