# elasticacheのパラメータ設定
resource "aws_elasticache_parameter_group" "ecache_example" {
  name   = "ecache-example"
  family = "redis6.x"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
}

# elasticacheのサブネットグループ
resource "aws_elasticache_subnet_group" "ecache_subnet" {
  name = "ecache-example"
  subnet_ids = [
    var.private_subnet_0_id,
    var.private_subnet_1_id
  ]
}

# elasticacheのレプリケーショングループ
resource "aws_elasticache_replication_group" "ecache" {
  replication_group_id       = "ecache"
  description                = "cluster disabled"
  engine                     = "redis"
  engine_version             = "6.0"
  num_cache_clusters         = 3
  node_type                  = "cache.t3.medium"
  snapshot_window            = "09:10-10:10"
  snapshot_retention_limit   = 7
  maintenance_window         = "mon:10:10-mon:11:40"
  automatic_failover_enabled = true
  port                       = 6379
  apply_immediately          = false
  security_group_ids         = [module.redis_sg.security_group_id]
  parameter_group_name       = aws_elasticache_parameter_group.ecache_example.name
  subnet_group_name          = aws_elasticache_subnet_group.ecache_subnet.name
}

# redis用のsgを作成
module "redis_sg" {
  source       = "../network/sg"
  name         = "redis-sg"
  vpc_id       = var.vpc_id
  port         = 6379
  cider_blocks = [var.cidr_block]
}