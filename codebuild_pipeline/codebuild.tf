resource "aws_codebuild_project" "codebuild" {
  name         = "${var.resource_name_prefix}-codebuild-project"
  service_role = aws_iam_role.codebuild_pipeline_codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = var.codebuild_github_source
    git_clone_depth = 0
    buildspec       = file("./buildspec.yaml")

    git_submodules_config {
      fetch_submodules = false
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  vpc_config {
    security_group_ids = [aws_security_group.api_gateway_sg.id]
    subnets            = aws_subnet.private_subnet.*.id
    vpc_id             = aws_vpc.main.id
  }

  environment {
    compute_type                = var.codebuild_compute_type
    image                       = var.codebuild_compute_image
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