resource "aws_secretsmanager_secret" "ssh_key" {
  name        = "codebuild/ci_pipeline/ssh_key"
  description = "used for checking out from github repo"
}

resource "aws_secretsmanager_secret_version" "ssh_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.ssh_key.id
  secret_string = file("/Users/yufeng/.ssh/codebuild")
  lifecycle {
    ignore_changes = [secret_string]
  }
}