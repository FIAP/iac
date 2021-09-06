resource "aws_security_group" "sgmain" {
  name        = "${var.name_prefix}-${var.env}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.services_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.protocol
      cidr_blocks = var.list_ips
    }
  }

  tags = {
    Name                               = "Work Nagios Security Group"
    Terraform                          = "true"
    ambiente                           = var.env
    app                                = var.app
    modalidade                         = var.modalidade
    projeto                            = var.projeto
    "kubernetes.io/cluster/eks-finnet" = "${var.clustrer_eks == "" ?  var.clustrer_eks : "shared"}"
  }
}
