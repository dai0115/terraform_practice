output "ecs_cluster_name" {
    value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
    value = aws_ecs_service.aws_ecs_service.name
}

output "operation_instance_id" {
  value = aws_instance.ec2_instance.id
}