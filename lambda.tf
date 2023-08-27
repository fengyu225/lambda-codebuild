resource "aws_lambda_function" "ci_plan_pipeline" {
  function_name = "ci_plan_pipeline"
  role          = aws_iam_role.ci_plan_pipeline.arn

  image_uri    = "072422391281.dkr.ecr.us-east-1.amazonaws.com/lambda-codebuild:v1.5"
  package_type = "Image"
}