# プライベートサブネットの作成
resource "aws_subnet" "private_0" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"
}