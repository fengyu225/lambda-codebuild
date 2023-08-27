resource "aws_secretsmanager_secret" "secret" {
  for_each    = { for s in var.secrets : s.secret_name => s }
  name        = "${each.value.secret_name}"
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  for_each = { for s in var.secrets : s.secret_name => s }

  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = each.value.secret_string
  lifecycle {
    ignore_changes = [secret_string]
  }
}
