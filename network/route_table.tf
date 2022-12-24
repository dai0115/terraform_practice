# route tableの作成(public用)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
}

# routeの作成(public用)
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け((public用)
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# route tableの作成(private用)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
}

# NAT gateway用のルート定義(private用)
resource "aws_route" "nat" {
  route_table_id = aws_route_table.private.id
  nat_gateway_id = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルの関連付け(private用)
resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}