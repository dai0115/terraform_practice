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

output "alb_dns_name" {
  value = aws_alb.alb_example.dns_name
}