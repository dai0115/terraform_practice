resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/logs"
  retention_in_days = 30
}