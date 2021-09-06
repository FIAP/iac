resource "aws_route_table" "route-dmz" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-gw.id
  }

  tags = {
    Name       = "Work Public Route Table"
    Terraform  = "true"
    Ambiente   = var.ENV
    APP        = "cloudit"
    Projeto    = "cloudit"
  "kubernetes.io/cluster/${var.cluster-name}-${var.ENV}" = "shared" }
}

resource "aws_route_table_association" "vpc-dmz-2-a" {
  subnet_id      = aws_subnet.vpc-public-0.id
  route_table_id = aws_route_table.route-dmz.id
}
