resource "aws_codebuild_project" "example" {
  name         = "example-project-api-gateway-trigger"
  description  = "An example CodeBuild project created using Terraform with S3 as a source"
  service_role = aws_iam_role.ci_plan_codebuild.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/fengyu225/aws-terraform-lab.git"
    git_clone_depth = 0
    buildspec       = file("${path.module}/buildspec.yaml")

    git_submodules_config {
      fetch_submodules = false
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  vpc_config {
    security_group_ids = [aws_security_group.api_gateway_sg.id]
    subnets            = [aws_subnet.private_subnet.id]
    vpc_id             = aws_vpc.main.id
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "072422391281.dkr.ecr.us-east-1.amazonaws.com/codebuild:v1.5"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "S3_OBJECT_KEY"
      value = "Yu-resume.pdf"
    }

    environment_variable {
      name  = "PHID"
      value = "foo"
    }

    environment_variable {
      name  = "DIFF_ID"
      value = "foo"
    }

    environment_variable {
      name  = "REVISION_ID"
      value = "foo"
    }
  }
}