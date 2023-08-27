variable "api_gateway_request_path" {
  description = "Request path for triggering CodeBuild through API Gateway"
  type        = string
  default     = "ci_plan_invoke"
}

variable "api_gateway_request_method" {
  description = "Request method for triggering CodeBuild through API Gateway"
  type        = string
  default     = "POST"
}

variable "api_gateway_stage_name" {
  type    = string
  default = "api"
}

variable "resource_name_prefix" {
  type    = string
  default = "ci-plan-pipeline"
}

variable "codebuild_github_source" {
  type    = string
  default = ""
}

variable "codebuild_compute_type" {
  type    = string
  default = "BUILD_GENERAL1_MEDIUM"
}

variable "codebuild_compute_image" {
  type    = string
  default = ""
}

variable "codebuild_lambda_image" {
  type    = string
  default = ""
}

variable "secrets" {
  description = "List of secrets to create"
  type        = list(object({
    secret_name   = string
    secret_string = string
  }))
  default = []
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24"]  # Default value as an example, you can adjust accordingly
}

variable "private_subnets" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24"]  # Default value as an example, you can adjust accordingly
}