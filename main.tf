module "s3" {
  source = "./s3"
}

module "network" {
  source = "./network"
  alb_bucket = module.s3.alb_log_id
  dns_name = var.dns_name
}

module "compting" {
  source = "./computing"
  private_subnet_0_id = module.network.private_subnet_0_id
  private_subnet_1_id = module.network.private_subnet_1_id
  target_group_arn = module.network.target_group_arn
  cidr_block = module.network.cidr_block
  vpc_id = module.network.vpc_id
}

module "encryption" {
  source = "./encryption"
  operation_bucket_id = module.s3.operation_bucket_id
  operation_log_name = module.compting.operation_log_name
}

module "db" {
  source = "./db"
  private_subnet_0_id = module.network.private_subnet_0_id
  private_subnet_1_id = module.network.private_subnet_1_id
  kms_key_arn = module.encryption.kms_key_arn
  cidr_block = module.network.cidr_block
  vpc_id = module.network.vpc_id
}

module "cicd" {
  source = "./cicd"
  ecs_cluster_name = module.compting.ecs_cluster_name
  ecs_service_name = module.compting.ecs_service_name
  artifact_bucket_id = module.s3.artifact_bucket_id
}

output "domain_name" {
  value = module.network.domain_name
}