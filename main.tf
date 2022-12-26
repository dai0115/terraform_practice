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