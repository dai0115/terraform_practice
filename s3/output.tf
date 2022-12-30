output "alb_log_id" {
  value = aws_s3_bucket.alb_log.id
}

output "artifact_bucket_id" {
  value = aws_s3_bucket.artifact.id
}