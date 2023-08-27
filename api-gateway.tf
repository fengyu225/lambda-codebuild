# https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/serverless-with-aws-lambda-and-api-gateway
resource "aws_security_group" "api_gateway_sg" {
  name   = "ci_plan_pipeline"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "api_gateway_sg_ingress" {
  type              = "ingress"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.api_gateway_sg.id
}

resource "aws_security_group_rule" "api_gateway_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.api_gateway_sg.id
}

resource "aws_api_gateway_rest_api" "ci_plan_rest_api" {
  name        = "ci_plan_pipeline_api"
  description = "Terraform Serverless Plan Pipeline"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.lambda_vpce.id]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.ci_plan_rest_api.id
  parent_id   = aws_api_gateway_rest_api.ci_plan_rest_api.root_resource_id
  path_part   = "ci_plan_invoke"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.ci_plan_rest_api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "apigw_lambda" {
  rest_api_id = aws_api_gateway_rest_api.ci_plan_rest_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ci_plan_pipeline.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.ci_plan_rest_api.id
  resource_id   = aws_api_gateway_rest_api.ci_plan_rest_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.ci_plan_rest_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  type              = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_deployment" "apigw_deploy" {
  depends_on = [
    aws_api_gateway_integration.apigw_lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.ci_plan_rest_api.id
}

resource "aws_api_gateway_stage" "apigw_stage" {
  deployment_id = aws_api_gateway_deployment.apigw_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.ci_plan_rest_api.id
  stage_name    = "api"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ci_plan_pipeline.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.ci_plan_rest_api.execution_arn}/*/*"
}

resource "aws_api_gateway_rest_api_policy" "parameter_store_policy" {
  rest_api_id = aws_api_gateway_rest_api.ci_plan_rest_api.id
  policy      = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.ci_plan_rest_api.execution_arn}/*"
        }
    ]
  }
EOF
}