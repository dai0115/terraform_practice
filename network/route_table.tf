# route tableの作成(public用)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

# routeの作成(public用)
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け(public用)
resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# route tableの作成(private用)
resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.vpc.id
}

# NAT gateway用のルート定義(private用)
resource "aws_route" "private_0" {
  route_table_id         = aws_route_table.private_0.id
  nat_gateway_id         = aws_nat_gateway.nat_0.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private_1.id
  nat_gateway_id         = aws_nat_gateway.nat_1.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け(private用)
resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}