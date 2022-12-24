# IGWの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
# elastic IPの作成
resource "aws_eip" "nat_gateway" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}

# NAT GWの作成
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id # 通信自体はパブリックサブネットを経由する
  depends_on = [
    aws_internet_gateway.igw
  ]
}



