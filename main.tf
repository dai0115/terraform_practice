module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}

module "network" {
  source = "./network"
  alb_bucket = module.s3.alb_log_id
}

module "security_group" {
  source = "./sg"
  name = "module-sg"
  vpc_id = module.network.vpc_id
  port = 80
  cider_blocks = [ "0.0.0.0/0" ]
}