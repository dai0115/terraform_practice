resource "aws_security_group" "sg_example" {
  name = var.name
  # vpc_id = module.network.vpc_id
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress_rule" {
  type = "ingress"
  from_port = var.port
  to_port = var.port
  protocol = "tcp"
  cidr_blocks = var.cider_blocks
  security_group_id = aws_security_group.sg_example.id
}

resource "aws_security_group_rule" "egress_rule" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_example.id
}

output "security_group_id" {
  value = aws_security_group.sg_example.id
}