resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "username for Database"
  overwrite   = true

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_raw_password" {
  name        = "/db/raw_password"
  value       = "uninitialized"
  type        = "SecureString"
  description = "password for Database"
  overwrite   = true

  lifecycle {
    ignore_changes = [value]
  }
}

# SSM document
resource "aws_ssm_document" "session_manger_run_shell" {
  name            = "SSMSessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<EOF
    {
      "schemaVersion": "1.0",
      "description": "Document to hold regional settings for Session Manager",
      "sessionType": "Standard_Stream",
      "inputs": {
        "s3BucketName": "${var.operation_bucket_id}",
        "cloudWatchLogGroupName": "${var.operation_log_name}"
      }
    }
  EOF
}