# databaseに設定するパラメータの定義
resource "aws_db_parameter_group" "parameter_example" {
  name = "parameterexample"
  family = "mysql5.7"
  parameter {
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name = "character_set_server"
    value = "utf8mb4"
  }
}

# DBオプショングループの定義
# データベースエンジンへのオプション機能の追加
resource "aws_db_option_group" "option_example" {
  name = "optionexample"
  engine_name = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

# DBサブネットグループの設定
# どのサブネットでDBを起動するかを定義
resource "aws_db_subnet_group" "db_subnet_group_example" {
  name = "db_subnet_group_example"
  subnet_ids = [
    var.private_subnet_0_id,
    var.private_subnet_1_id
    ]
}

# DBインスタンスの作成
resource "aws_db_instance" "instance_example" {
  identifier = "instanceexample"
  engine = "mysql"
  engine_version = "5.7.40"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  max_allocated_storage = 100
  storage_type = "gp2"
  storage_encrypted = true
  kms_key_id = var.kms_key_arn
  username = "admin"
  password = "VeryStrongPassword!"
  multi_az = true
  publicly_accessible = false
  backup_window = "09:10-09:40"
  backup_retention_period = 10
  maintenance_window = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection = false # 実運用などではtrue
  skip_final_snapshot = true # 実運用などではfalse
  port = 3306
  apply_immediately = false
  vpc_security_group_ids = [module.db_sg.security_group_id]
  parameter_group_name = aws_db_parameter_group.parameter_example.name
  option_group_name = aws_db_option_group.option_example.name
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group_example.name

  lifecycle {
    ignore_changes = [password]
  }
}

# dbインスタンス用のセキュリティグループを作成
module "db_sg" {
  source = "../network/sg"
  name = "db_sg"
  port = 3306
  vpc_id = var.vpc_id
  cider_blocks = [ var.cidr_block ]
}