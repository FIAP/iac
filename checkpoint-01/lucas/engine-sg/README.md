# SG-eks

Documentação para uso do módulo
## Apontamento

Realizar o clone do repositório ou apontar o source para o repo do git



## Utilização 

Criar o diretório com o nome de projeto ou ambiente, criar os arquivos, provider.tf, vars.tf, backend.tf, output.tf e por fim abaixo o exemplo de arquivo para utilização do módulo cujo o nome pode ser ambiente "SANDBOX.tf" :

```
data "aws_vpc" "default" {
  filter {
    name = "tag:Name"
    values = ["ECS corp-finnet-cluster - VPC"]
  }
}
module "sg" {
  source             = "../"
  name_prefix        = var.name_prefix
  env                = var.env
  app                = var.app
  modalidade         = var.modalidade
  projeto            = var.projeto
  clustrer_eks       = var.clustrer_eks
  vpc_id             = data.aws_vpc.default.id
  services_ports     = var.services_ports
  list_ips           = [data.aws_vpc.default.cidr_block]
} 

terraform init 
terraform validate
terraform plan -out exemplo
terraform apply exemplo 
