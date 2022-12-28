resource "aws_ssm_parameter" "db_username" {
  name = "/db/username"
  value = "root"
  type = "String"
  description = "username for Database"
}

resource "aws_ssm_parameter" "db_raw_password" {
  name = "/db/raw_password"
  value = "uninitialized"
  type = "SecureString"
  description = "password for Database"

  lifecycle {
    ignore_changes = [value]
  }
}
