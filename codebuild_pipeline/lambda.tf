resource "aws_lambda_function" "codebuild_pipeline_lambda" {
  function_name = "${var.resource_name_prefix}-codebuild-pipeline-lambda"
  role          = aws_iam_role.codebuild_pipeline_lambda_role.arn

  image_uri    = var.codebuild_lambda_image
  package_type = "Image"
}