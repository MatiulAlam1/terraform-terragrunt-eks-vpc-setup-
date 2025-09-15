EKS VPC Setup with Terraform and Terragrunt
===========================================

Overview
--------

This project provides a reusable and configurable setup to provision a Virtual Private Cloud (VPC) on AWS, specifically designed to meet the requirements for hosting an Amazon EKS (Elastic Kubernetes Service) cluster. It uses Terraform for infrastructure as code and Terragrunt to keep the configuration DRY (Don't Repeat Yourself) and manage remote state.

The resulting VPC includes:

*   Public and private subnets across multiple Availability Zones.
    
*   An Internet Gateway (IGW) for public internet access.
    
*   NAT Gateways in public subnets to allow private subnets to access the internet.
    
*   Appropriate route tables for public and private subnets.
    
*   Necessary tags on all resources, especially those required by EKS for auto-discovery (e.g., kubernetes.io/cluster/).
    

Prerequisites
-------------

Before you begin, ensure you have the following installed:

*   [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.0.0 or newer)
    
*   [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (v0.36.0 or newer)
    
*   [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials.
    

You will also need an S3 bucket and a DynamoDB table for managing Terraform's remote state and locking. Terragrunt can create these for you automatically if they don't exist.

Project Structure
-----------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   .  ├── terragrunt.hcl  ├── vpc  │   ├── main.tf  │   ├── variables.tf  │   └── outputs.tf  └── README.md   `

*   **terragrunt.hcl**: The main Terragrunt configuration file. It defines the remote state backend (S3 and DynamoDB), specifies the location of the Terraform module, and provides the input variables required by the module.
    
*   **vpc/**: This directory contains the underlying Terraform module responsible for creating the VPC resources.
    
    *   **main.tf**: Defines the AWS resources (VPC, subnets, gateways, etc.).
        
    *   **variables.tf**: Declares the input variables for the VPC module.
        
    *   **outputs.tf**: Defines the outputs of the module (e.g., VPC ID, subnet IDs).
        

Configuration
-------------

The primary configuration happens in the root terragrunt.hcl file. This is where you will set all the variables for your specific environment.

### Example terragrunt.hcl

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   # Configure remote state management  remote_state {    backend = "s3"    generate = {      path      = "backend.tf"      if_exists = "overwrite_terragrunt"    }    config = {      bucket         = "your-terraform-state-bucket-name"      key            = "${path_relative_to_include()}/terraform.tfstate"      region         = "us-east-1"      encrypt        = true      dynamodb_table = "your-terraform-lock-table"    }  }  # Define the location of the Terraform module  terraform {    source = "./vpc"  }  # --- VPC Module Inputs ---  # Pass variables to the underlying Terraform module.  inputs = {    aws_region = "us-east-1"    vpc_name   = "my-eks-vpc"    cidr_block = "10.0.0.0/16"    # Define subnets across 3 Availability Zones    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]    public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]    private_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]    # Enable NAT Gateway for private subnets (recommended for EKS)    enable_nat_gateway = true    single_nat_gateway = false # Set to true to use one NAT Gateway for all AZs    # Tags required by EKS    tags = {      Terraform   = "true"      Environment = "dev"    }    # EKS requires these tags on subnets for the load balancer controller and cluster auto-discovery    eks_cluster_name = "my-eks-cluster"  }   `

Usage
-----

Navigate to the root directory of this project where the terragrunt.hcl file is located and run the following commands:

### Initialize Terragrunt

This command downloads the necessary Terraform providers and configures the remote state backend.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terragrunt init   `

### Plan the Deployment

This command creates an execution plan, showing you what resources will be created, modified, or destroyed. It's a dry run to verify changes before applying them.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terragrunt plan   `

### Apply the Configuration

This command provisions the VPC and all related resources in your AWS account. You will be prompted to confirm the action.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terragrunt apply   `

### View the Outputs

After the apply is successful, you can view the defined outputs, such as the VPC ID and subnet IDs. You will need these for configuring your EKS cluster.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terragrunt output   `

### Destroy the Infrastructure

This command will tear down all the resources created by this configuration. Use with caution.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   terragrunt destroy   `

Module Inputs
-------------

The following variables can be configured in the inputs = {} block of your terragrunt.hcl file.

NameDescriptionTypeDefaultRequiredaws\_regionThe AWS region where resources will be created.stringus-east-1Yesvpc\_nameThe name of the VPC.stringnullYescidr\_blockThe primary CIDR block for the VPC.string10.0.0.0/16Yesavailability\_zonesA list of Availability Zones to create subnets in.list(string)\[\]Yespublic\_subnetsA list of CIDR blocks for the public subnets. Must match the number of AZs.list(string)\[\]Yesprivate\_subnetsA list of CIDR blocks for the private subnets. Must match the number of AZs.list(string)\[\]Yesenable\_nat\_gatewayIf true, creates NAT Gateways for private subnet internet access.booltrueNosingle\_nat\_gatewayIf true, creates a single NAT Gateway instead of one per AZ.boolfalseNotagsA map of common tags to apply to all resources.map(string){}Noeks\_cluster\_nameThe name of the EKS cluster. Used to apply required EKS-specific tags.stringnullYes

Module Outputs
--------------

NameDescriptionvpc\_idThe ID of the created VPC.public\_subnet\_idsA list of IDs for the public subnets.private\_subnet\_idsA list of IDs for the private subnets.igw\_idThe ID of the Internet Gateway.nat\_gateway\_eipsA list of Elastic IP addresses for the NAT Gateways.
