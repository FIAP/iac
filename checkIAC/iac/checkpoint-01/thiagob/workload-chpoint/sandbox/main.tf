provider "aws" {
  region = "us-east-1"
}

module "vpca"{
    source = "../../engine-vpc/"
        AWS_REGION = "us-east-1"
        CIDRVPC = "10.0.0.0/16"
        map_public_true = "true" 
        cloudit_DMZ_A = "us-east-1a"
        CIDR_cloudit_DMZ_A = "10.0.0.0/24" 
        instance_tenancy = "default"
        enable_dns_support = "true"
        enable_dns_hostnames = "true"
        enable_classiclink = "false"
        name_vpc = "work-vpc"
        ENV = "work-vpc"
        cluster-name = "work-vpc"
}

module "sg_nagios" {
  source             = "../../engine-sg/"
  name_prefix        = "sg_vpc_10_public"
  env                = "sg_vpc_10_public"
  app                = "sg_vpc_10_public"
  modalidade         = "sg_vpc_10_public"
  projeto            = "sg_vpc_10_public"
  clustrer_eks       = "sg_vpc_10_public"
  vpc_id             = module.vpca.vpc
  services_ports     = ["22","80","3389"]
  protocol           = "tcp"
  list_ips = ["10.0.0.0/16","0.0.0.0/0"]
}



module "nagios" {
  source             = "../../engine-ec2/"
  ami                = "ami-087c17d1fe0178315"
  type_instance      = var.type_instance
  ip_public          = true
  key_ssh_name       = var.key_ssh_name
  type_volume        = var.type_volume
  size_volume        = var.size_volume
  del_on_termination = var.del_on_termination
  private_ip         = "10.0.0.15"
  vpc_security_group_ids = [module.sg_nagios.sgoutput]
  subnet_id          = module.vpca.subnet-dmz-0
  tag                = "Nagios"
}

module "node_a" {
  source             = "../../engine-ec2/"
  ami                = "ami-087c17d1fe0178315"
  type_instance      = var.type_instance
  ip_public          = true
  key_ssh_name       = var.key_ssh_name
  type_volume        = var.type_volume
  size_volume        = var.size_volume
  del_on_termination = var.del_on_termination
  private_ip         = "10.0.0.14"
  vpc_security_group_ids = [module.sg_nagios.sgoutput]
  subnet_id          = module.vpca.subnet-dmz-0
  tag                = "Node_a"
}
