module "iam" {
  source = "./iam"
}

module "s3" {
  source = "./s3"
}

module "network" {
  source = "./network"
}