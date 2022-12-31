# webサーバのロギング用
resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/logs"
  retention_in_days = 30
}

# ECSタスクスケジュール用
resource "aws_cloudwatch_log_group" "for_batch" {
  name = "/ecs/scheduled-tasks/example"
  retention_in_days = 30
}

# cloudwatch logs用
resource "aws_cloudwatch_log_group" "operation" {
  name = "/operation"
  retention_in_days = 30
}