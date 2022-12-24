# IGWの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
# elastic IPの作成
resource "aws_eip" "nat_gateway_0" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_eip" "nat_gateway_1" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}
# NAT GWの作成
resource "aws_nat_gateway" "nat_0" {
  allocation_id = aws_eip.nat_gateway_0.id
  subnet_id = aws_subnet.public_0.id # 通信自体はパブリックサブネットを経由する
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id = aws_subnet.public_0.id # 通信自体はパブリックサブネットを経由する
  depends_on = [
    aws_internet_gateway.igw
  ]
}


