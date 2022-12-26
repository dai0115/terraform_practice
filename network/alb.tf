resource "aws_alb" "alb_example" {
  name = "albexample"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = true

  subnets = [ 
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
    ]

    access_logs {
      bucket = var.alb_bucket
      enabled = true
    }

    security_groups = [
        module.http_sg.security_group_id,
        module.https_sg.security_group_id,
        module.http_redirect_sg.security_group_id,
    ]
}


module "http_sg" {
  source = "./sg"
  name = "http-sg"
  vpc_id = aws_vpc.vpc.id
  port = 80
  cider_blocks = [ "0.0.0.0/0" ]
}

module "https_sg" {
  source = "./sg"
  name = "https-sg"
  vpc_id = aws_vpc.vpc.id
  port = 443
  cider_blocks = [ "0.0.0.0/0" ]
}

module "http_redirect_sg" {
  source = "./sg"
  name = "http_redirect-sg"
  vpc_id = aws_vpc.vpc.id
  port = 8080
  cider_blocks = [ "0.0.0.0/0" ]
}

output "alb_dns_name" {
  value = aws_alb.alb_example.dns_name
}