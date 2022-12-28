# ECSクラスタ
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_example"
}

# webサーバ用タスク定義
 resource "aws_ecs_task_definition" "task_definition" {
   family = "task-definition"
   cpu = 256
   memory = 512
   network_mode = "awsvpc"
   requires_compatibilities = [ "FARGATE" ]
   container_definitions = file("./computing/container_definition.json")
   execution_role_arn = module.ecs_task_execution_role.iam_role_arn # cloudwatch logsへのロギング用のロール
}

# バッチ用タスク定義
 resource "aws_ecs_task_definition" "batch_example" {
   family = "batch_example"
   cpu = 256
   memory = 512
   network_mode = "awsvpc"
   requires_compatibilities = [ "FARGATE" ]
   container_definitions = file("./computing/batch_container_definition.json")
   execution_role_arn = module.ecs_task_execution_role.iam_role_arn # cloudwatch logsへのロギング用のロール
}

# cloudwatchイベントルールの設定
resource "aws_cloudwatch_event_rule" "batch_example" {
  name = "batch_example"
  description = "this is cloudwatch event rule to trigger ecs scheduled tasks"
  schedule_expression = "cron(*/2 * * * ? *)"
}

# cloudwatchイベントルールとECSタスクターゲットを紐付ける
resource "aws_cloudwatch_event_target" "batch_example" {
  target_id = "batch_example"
  rule = aws_cloudwatch_event_rule.batch_example.name
  role_arn = module.ecs_events_role.iam_role_arn
  arn = aws_ecs_cluster.ecs_cluster.arn

  ecs_target {
    launch_type = "FARGATE"
    task_count = 1
    platform_version = "1.4.0"
    task_definition_arn = replace(aws_ecs_task_definition.batch_example.arn, "/:\\d+$/", "")

    network_configuration {
      assign_public_ip = "false"
      subnets = [var.private_subnet_0_id]
    }
  }

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
    source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

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

# scheduled-task実行のためのcloudwatch eventsIAMロール
module "ecs_events_role" {
  source = "../iam"
  name = "ecs-events"
  identifier = "events.amazonaws.com"
  policy = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}