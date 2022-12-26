output "alb_dns_name" {
  value = aws_alb.alb_example.dns_name
}

output "domain_name" {
  value = aws_route53_record.record_example.name
}