resource "aws_alb" "alb_example" {
  name                       = "albexample"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket  = var.alb_bucket
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

# albにアタッチするsgモジュールを生成
module "http_sg" {
  source       = "../security_group"
  name         = "http-sg"
  vpc_id       = aws_vpc.vpc.id
  port         = 80
  cider_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source       = "../security_group"
  name         = "https-sg"
  vpc_id       = aws_vpc.vpc.id
  port         = 443
  cider_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source       = "../security_group"
  name         = "http_redirect-sg"
  vpc_id       = aws_vpc.vpc.id
  port         = 8080
  cider_blocks = ["0.0.0.0/0"]
}

# httpリスナー
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.alb_example.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「http」です"
      status_code  = 200
    }
  }
}

# httpsリスナー
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.alb_example.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.certificate_validation.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「https」です"
      status_code  = 200
    }
  }
}

# リダイレクト用リスナー
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_alb.alb_example.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "tg_example" {
  name                 = "tgExample"
  target_type          = "ip" # ECS Fargateの場合は、ipを指定
  vpc_id               = aws_vpc.vpc.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/" # ヘルスチェックに利用するパス
    healthy_threshold   = 5   # 正常判定を行うまでのヘルスチェック実行回数
    unhealthy_threshold = 2   # 以上判定を行うまでのヘルスチェック実行回数
    timeout             = 5
    interval            = 30  # 実行間隔
    matcher             = 200 # 正常判定時のHTTPステータスコード
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [
    aws_alb.alb_example
  ]
}

resource "aws_lb_listener_rule" "listener_rule_example" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_example.arn
  }

  condition {
    path_pattern {
      values = ["/*"] #全てのパスへのアクセスを該当のtgにフォワード
    }
  }

}