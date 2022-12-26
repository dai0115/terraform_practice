# ホストゾーンの作成
resource "aws_route53_zone" "route53_example" {
  name = "daitestdns.tk"
}

# DNSレコードの作成
resource "aws_route53_record" "record_example" {
  zone_id = aws_route53_zone.route53_example.id
  name = aws_route53_zone.route53_example.name

  type = "A"
  alias {
    name = aws_alb.alb_example.dns_name
    zone_id = aws_alb.alb_example.zone_id
    evaluate_target_health = true
  }
}