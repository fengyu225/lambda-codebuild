# api_gateway_cloudwatch_global
resource "aws_iam_role" "api_gateway_cloudwatch_global" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role.json
}

data "aws_iam_policy_document" "apigateway_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "apigw_cloudwatch_logs_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_apigw_cloudwatch" {
  name   = "ci_plan_allow_apigw_cloudwatch"
  role   = aws_iam_role.api_gateway_cloudwatch_global.id
  policy = data.aws_iam_policy_document.apigw_cloudwatch_logs_permissions.json
}


# ci_plan_pipeline
resource "aws_iam_role" "ci_plan_pipeline" {
  name               = "ci_plan_pipeline"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "lambda_allow_codebuild" {
  name   = "lambda_allow_codebuild"
  role   = aws_iam_role.ci_plan_pipeline.name
  policy = data.aws_iam_policy_document.lambda_allow_codebuild.json
}

data "aws_iam_policy_document" "lambda_allow_codebuild" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "codebuild:StartBuild",
    ]
  }
}

# ci_plan_codebuild
resource "aws_iam_role" "ci_plan_codebuild" {
  name               = "ci_plan_codebuild"
  assume_role_policy = data.aws_iam_policy_document.code_build_assume_role.json
}

data "aws_iam_policy_document" "code_build_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "ci_plan_codebuild" {
  role   = aws_iam_role.ci_plan_codebuild.name
  policy = data.aws_iam_policy_document.ci_plan_codebuild.json
}

data "aws_iam_policy_document" "ci_plan_codebuild" {
  source_policy_documents = [
    data.aws_iam_policy_document.codebuild_ecr_access.json,
    data.aws_iam_policy_document.codebuild_s3_access.json,
    data.aws_iam_policy_document.codebuild_allow_ecr.json,
    data.aws_iam_policy_document.codebuild_ec2.json,
    data.aws_iam_policy_document.codebuild_logs.json,
    data.aws_iam_policy_document.codebuild_secrets_manager.json,
    data.aws_iam_policy_document.codebuild_sts.json,
  ]
}

data "aws_iam_policy_document" "codebuild_ecr_access" {
  statement {
    sid     = "CodeBuildECRAccessPolicy"
    effect  = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = [
      "arn:aws:ecr:us-east-1:072422391281:repository/lambda-codebuild",
      "arn:aws:ecr:us-east-1:072422391281:repository/codebuild"
    ]
  }
}

data "aws_iam_policy_document" "codebuild_s3_access" {
  statement {
    sid     = "CodeBuildS3AccessPolicy"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::test-bucket-21151",
      "arn:aws:s3:::test-bucket-21151/home/test/*"
    ]
  }
}

data "aws_iam_policy_document" "codebuild_allow_ecr" {
  statement {
    sid       = "ecr"
    effect    = "Allow"
    resources = ["arn:aws:ecr:us-east-1:072422391281:repository/codebuild"]
    actions   = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings"
    ]
  }

  statement {
    sid       = "ecrAuthZ"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "ecr:GetAuthorizationToken",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_ec2" {
  statement {
    sid       = "ec2"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpc*",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeVolumes",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeAddresses",
      "ec2:DescribeTags",
      "ec2:DeleteNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_logs" {
  statement {
    sid       = "logs"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "logs:Get*",
      "logs:List*",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_secrets_manager" {
  statement {
    sid       = "secretsManagerGetsecret"
    effect    = "Allow"
    resources = [
      "arn:aws:secretsmanager:us-east-1:072422391281:secret:codebuild/ci_pipeline/*"
    ]
    actions = [
      "secretsmanager:GetSecretValue",
    ]
  }
  statement {
    sid       = "secretsManagerList"
    effect    = "Allow"
    resources = ["*"]
    actions   = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_sts" {
  statement {
    sid       = "TerraformCIROAssume"
    effect    = "Allow"
    resources = [
      "arn:aws:iam::*:role/terraform_ci_ro"
    ]
    actions = [
      "sts:AssumeRole",
    ]
  }
}