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

output "domain_name" {
  value = module.network.domain_name
}