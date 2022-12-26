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

# httpリスナー
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

# httpsリスナー
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.alb_example.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.acm_example.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「https」です"
      status_code = 200
    }
  }
}

# リダイレクト用リスナー
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_alb.alb_example.arn
  port = 8080
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}