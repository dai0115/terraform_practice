variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "artifact_bucket_id" {}

locals {
  github_repository_name = "dai0115/sample_project"
  branch_name = "main"
}