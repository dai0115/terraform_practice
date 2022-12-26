resource "aws_alb" "alb_example" {
  name = "albexample"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = false

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

# リスナーの作成
# httpリスエストに対するレスポンス
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb_example.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「http」です"
      status_code = 200
    }
  }
}