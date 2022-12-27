# ECSクラスタ
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_example"
}

# タスク定義
 resource "aws_ecs_task_definition" "task_definition" {
   family = "task-definition"
   cpu = 256
   memory = 512
   network_mode = "awsvpc"
   requires_compatibilities = [ "FARGATE" ]
   container_definitions = file("./computing/container_definition.json")
}

# ECSサービス
resource "aws_ecs_service" "aws_ecs_service" {
  name = "ecs_service"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [ 
    module.nginx_sg.security_group_id
    ]

    subnets = [ 
        var.private_subnet_0_id,
        var.private_subnet_1_id
    ]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = "container_definition"
    container_port = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

module "nginx_sg" {
    source = "../network/sg"
    name = "nginx-sg"
    vpc_id = var.vpc_id
    port = 80
    cider_blocks = [ var.cidr_block ]
}