# Makefile for CodeBuild Pipeline Project

# Variables
LAMBDA_DIR := lambda-code
CODEBUILD_DIR := codebuild-code
LAMBDA_IMAGE_NAME := codebuild-pipeline-lambda
CODEBUILD_IMAGE_NAME := codebuild-pipeline-codebuild
ECR_REPO := your-account-id.dkr.ecr.your-region.amazonaws.com

# AWS CLI commands
AWS_ECR_LOGIN := aws ecr get-login-password --region your-region | docker login --username AWS --password-stdin $(ECR_REPO)

.PHONY: all build-lambda build-codebuild push-lambda push-codebuild deploy terraform-apply clean

all: build-lambda build-codebuild push-lambda push-codebuild deploy

# Build Docker images
build-lambda:
	@echo "Building Lambda image..."
	docker build -t $(LAMBDA_IMAGE_NAME) $(LAMBDA_DIR)

build-codebuild:
	@echo "Building CodeBuild image..."
	docker build -t $(CODEBUILD_IMAGE_NAME) $(CODEBUILD_DIR)

# Push images to ECR
push-lambda:
	@echo "Logging in to ECR..."
	@$(AWS_ECR_LOGIN)
	@echo "Pushing Lambda image to ECR..."
	docker tag $(LAMBDA_IMAGE_NAME):latest $(ECR_REPO)/$(LAMBDA_IMAGE_NAME):latest
	docker push $(ECR_REPO)/$(LAMBDA_IMAGE_NAME):latest

push-codebuild:
	@echo "Logging in to ECR..."
	@$(AWS_ECR_LOGIN)
	@echo "Pushing CodeBuild image to ECR..."
	docker tag $(CODEBUILD_IMAGE_NAME):latest $(ECR_REPO)/$(CODEBUILD_IMAGE_NAME):latest
	docker push $(ECR_REPO)/$(CODEBUILD_IMAGE_NAME):latest

# Deploy infrastructure
deploy: terraform-apply

# Terraform apply
terraform-apply:
	@echo "Applying Terraform configuration..."
	terraform init
	terraform apply

# Clean up
clean:
	@echo "Cleaning up..."
	docker rmi $(LAMBDA_IMAGE_NAME) $(CODEBUILD_IMAGE_NAME)
	docker rmi $(ECR_REPO)/$(LAMBDA_IMAGE_NAME):latest $(ECR_REPO)/$(CODEBUILD_IMAGE_NAME):latest

# Helper target to update ECR login
update-ecr-login:
	@echo "Updating ECR login..."
	@$(AWS_ECR_LOGIN)