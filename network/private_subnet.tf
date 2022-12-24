# プライベートサブネットの作成
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
}