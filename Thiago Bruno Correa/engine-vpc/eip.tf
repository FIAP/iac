# Internet GW
resource "aws_internet_gateway" "vpc-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name                             = "Work IGW"
    Terraform                        = "true"
    Ambiente                         = var.ENV
    APP                              = "main"
    Projeto                          = "main"
    
    "kubernetes.io/cluster/teste" = "shared"
  }
}