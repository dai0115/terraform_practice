resource "aws_acm_certificate" "acm_example" {
  domain_name = aws_route53_record.record_example.name
  subject_alternative_names = [ ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# 検証用DNSレコードの作成
resource "aws_route53_record" "certificate_example" {
  for_each = {
    for dvo in aws_acm_certificate.acm_example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
      zone_id = aws_route53_zone.route53_example.zone_id
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [ each.value.record ]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.route53_example.zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_example.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_example : record.fqdn]
}