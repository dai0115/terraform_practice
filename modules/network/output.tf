output "alb_dns_name" {
  value = aws_alb.alb_example.dns_name
}

output "domain_name" {
  value = aws_route53_record.record_example.name
}

output "private_subnet_0_id" {
  value = aws_subnet.private_0.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "target_group_arn" {
  value = aws_lb_target_group.tg_example.arn
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}