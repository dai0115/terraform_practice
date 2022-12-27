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
   execution_role_arn = module.ecs_task_execution_role.iam_role_arn # cloudwatch logsへのロギング用のロール
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

# ECSの基本的な実行権限に関するポリシーを参照
data "aws_iam_policy" "ecs_task_execution_role_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# SSMパラメータストアとECSを結合するため実行ポリシーを定義
data "aws_iam_policy_document" "ecs_task_execution" {
    source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

    statement {
      effect = "Allow"
      actions = ["ssm:GetParameters", "kms:Decrypt"]
      resources = ["*"]
    }
}

# ECSと関連付けるIAMロール
# タスク定義に関連付けて、そこから生成されたタスクも実行権限を得る
module "ecs_task_execution_role" {
  source = "../iam"
  name = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}