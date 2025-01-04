# My Terraform Project

This project is a Terraform configuration for managing AWS infrastructure, specifically focusing on creating Virtual Private Clouds (VPCs) and subnets. The real focus for me during this project is learning a new tool for me : Github Copilot, an AI assistant. Also, working with Github as a vcs, VSC as a dev environment, Terraform, and behind it all, getting hands-on experience building out AWS resources and utilizing services. Cool stuff!

## Project Structure

```
my-terraform-project
├── main.tf                # Main configuration file for the Terraform project
├── variables.tf           # Input variables for the Terraform project
├── outputs.tf             # Output values for the Terraform project
├── terraform.tfvars       # Variable values for the Terraform project
├── modules                # Directory containing reusable modules
│   ├── vpc                # Module for VPC creation
│   │   ├── main.tf        # Configuration for the VPC module
│   │   ├── variables.tf   # Input variables for the VPC module
│   │   └── outputs.tf     # Output values for the VPC module
│   ├── subnet             # Module for subnet creation
│   │   ├── main.tf        # Configuration for the subnet module
│   │   ├── variables.tf   # Input variables for the subnet module
│   │   └── outputs.tf     # Output values for the subnet module
└── README.md              # Documentation for the project
```

## Setup Instructions

1. **Install Terraform**: Ensure you have Terraform installed on your machine. You can download it from the [Terraform website](https://www.terraform.io/downloads.html).

2. **Clone the Repository**: Clone this repository to your local machine.

3. **Navigate to the Project Directory**: Change into the project directory.

   ```
   cd my-terraform-project
   ```

4. **Initialize Terraform**: Run the following command to initialize the Terraform project.

   ```
   terraform init
   ```

5. **Configure Variables**: Edit the `terraform.tfvars` file to set your desired variable values.

6. **Plan the Infrastructure**: Run the following command to see what changes will be made.

   ```
   terraform plan
   ```

7. **Apply the Configuration**: If the plan looks good, apply the configuration to create the resources.

   ```
   terraform apply
   ```

## Usage

After applying the configuration, you can view the output values defined in `outputs.tf` to get information about the created resources, such as VPC IDs and subnet IDs.

## Modules

This project uses modules for better organization and reusability. The `vpc` module is responsible for creating VPCs, while the `subnet` module handles subnet creation. Each module has its own set of input variables and output values.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.