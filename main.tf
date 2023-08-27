module "codebuild_pipeline" {
  source  = "./codebuild_pipeline"
  secrets = [
    {
      secret_name   = "codebuild/ci_pipeline/ssh_key2",
      secret_string = file("/Users/yufeng/.ssh/codebuild")
    }
  ]
  codebuild_compute_image = "072422391281.dkr.ecr.us-east-1.amazonaws.com/codebuild:v1.1"
  codebuild_lambda_image  = "072422391281.dkr.ecr.us-east-1.amazonaws.com/lambda-codebuild:v1.2"
  codebuild_github_source = "https://github.com/fengyu225/aws-terraform-lab.git"
}

output "api_gateway_url" {
  description = "API Gateway URL for the CodeBuild Pipeline"
  value       = module.codebuild_pipeline.api_gateway_url
}

# example command:
# curl -XPOST "https://c865w3lp8h.execute-api.us-east-1.amazonaws.com/api/ci_plan_invoke?diff_id=2092877&phid=PHID-HMBT-igwqn7vzelitghv23u2y&revision_id=570092"