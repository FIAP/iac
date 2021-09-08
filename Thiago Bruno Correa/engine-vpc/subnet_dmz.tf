resource "aws_subnet" "vpc-public-0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.CIDR_cloudit_DMZ_A
  map_public_ip_on_launch = true
  availability_zone       = var.cloudit_DMZ_A

  tags = {
    Name                                                   = "Work Public Subnet"
    Terraform                                              = true
    Ambiente                                               = var.ENV
    APP                                                    = "cloudit"
    Projeto                                                = "cloudit"
    "kubernetes.io/cluster/${var.cluster-name}-${var.ENV}" = "shared"

  }
}
