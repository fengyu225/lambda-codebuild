# CodeBuild Pipeline Project

This project sets up a CI/CD pipeline using AWS API Gateway, Lambda, and CodeBuild within a custom VPC. The pipeline is triggered by HTTP calls to API Gateway, which invokes a Lambda function that then starts a CodeBuild project.

## Overview

1. API Gateway receives an HTTP call
2. API Gateway triggers a Lambda function
3. Lambda function starts a CodeBuild project
4. CodeBuild executes the build process

All of this occurs within a custom VPC with private subnets and VPC endpoints for secure communication.

## Prerequisites

- AWS Account
- Terraform installed (version 0.12+)
- AWS CLI configured with appropriate credentials
- Docker (for building the Lambda and CodeBuild container images)
- Go 1.17 or later (for Lambda function development)

## Project Structure

```
├── buildspec.yaml
├── codebuild-code
│   ├── Dockerfile
│   └── hello-world.txt
├── codebuild_pipeline
│   ├── api-gateway.tf
│   ├── codebuild.tf
│   ├── data.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── outputs.tf
│   ├── secrets.tf
│   ├── variables.tf
│   ├── vpc.tf
│   └── vpce.tf
├── lambda-code
│   ├── Dockerfile
│   ├── go.mod
│   ├── go.sum
│   └── main.go
├── main.tf
├── provider.tf
└── Makefile
```

## Setup

1. Clone this repository:

2. Update the `main.tf` file with your specific values:

   ```hcl
   module "codebuild_pipeline" {
     source  = "./codebuild_pipeline"
     secrets = [
       {
         secret_name   = "codebuild/ci_pipeline/ssh_key2",
         secret_string = file("/path/to/your/ssh/key")
       }
     ]
     codebuild_compute_image = "your-account-id.dkr.ecr.your-region.amazonaws.com/codebuild:your-tag"
     codebuild_lambda_image  = "your-account-id.dkr.ecr.your-region.amazonaws.com/lambda-codebuild:your-tag"
     codebuild_github_source = "https://github.com/your-username/your-repo.git"
   }

   output "api_gateway_url" {
     description = "API Gateway URL for the CodeBuild Pipeline"
     value       = module.codebuild_pipeline.api_gateway_url
   }
   ```

3. Build the Lambda function and CodeBuild Docker images:
   ```
   make build-lambda
   make build-codebuild
   ```

4. Push the Docker images to Amazon ECR:
   ```
   make push-lambda
   make push-codebuild
   ```

5. Deploy the infrastructure:
   ```
   make deploy
   ```

## Components

### API Gateway
- Private endpoint within a VPC
- Configured to trigger a Lambda function

### Lambda Function
- Triggers the CodeBuild project
- Written in Go
- Packaged as a Docker container

### CodeBuild
- Uses a custom Docker image based on Ubuntu

### VPC
- Custom VPC with public and private subnets
- NAT Gateways for outbound internet access from private subnets
- VPC Endpoints for secure access to AWS services

### IAM
- Roles and policies for API Gateway, Lambda, and CodeBuild

### Secrets Manager
- Manages secrets required for the pipeline

## Usage

To trigger the pipeline, make a POST request to the API Gateway endpoint with the following query parameters:

- `diff_id`: The diff ID from your version control system
- `phid`: The PHID (Phabricator ID) if you're using Phabricator
- `revision_id`: The revision ID from your version control system

Example:
```
curl -XPOST "https://your-api-id.execute-api.your-region.amazonaws.com/api/ci_plan_invoke?diff_id=2092877&phid=PHID-HMBT-igwqn7vzelitghv23u2y&revision_id=570092"
```

The `api_gateway_url` is provided as an output after applying the Terraform configuration.

## Customization

1. VPC Configuration:
    - Modify `vpc_cidr_block`, `public_subnets`, and `private_subnets` in `codebuild_pipeline/variables.tf`

2. API Gateway:
    - Update `api_gateway_request_path` and `api_gateway_request_method` in `codebuild_pipeline/variables.tf`

3. Secrets:
    - Add or modify secrets in the `secrets` list in `main.tf`

4. Lambda Function:
    - Modify `lambda-code/main.go` to change the function's behavior

5. CodeBuild:
    - Update `codebuild-code/Dockerfile` to modify the CodeBuild environment
    - Change `codebuild-code/hello-world.txt` content as needed