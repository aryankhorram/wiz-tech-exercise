# Elastic IP for NAT Gateway
resource "aws_eip" "wiz_nat_gateway_ip" {
  domain = "vpc"
}

# NAT Gateway in the PUBLIC subnet
resource "aws_nat_gateway" "wiz_nat_gateway" {
  allocation_id = aws_eip.wiz_nat_gateway_ip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Route table for the PRIVATE subnet
resource "aws_route_table" "wiz_private_route_table" {
  vpc_id = aws_vpc.wiz_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wiz_nat_gateway.id
  }
}

# Associate private subnet with the new route table
resource "aws_route_table_association" "wiz_private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.wiz_private_route_table.id
}
