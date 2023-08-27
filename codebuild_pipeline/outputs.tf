output "api_gateway_url" {
  value = "https://${aws_api_gateway_deployment.apigw_deploy.rest_api_id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.api_gateway_stage_name}/${var.api_gateway_request_path}"
}
