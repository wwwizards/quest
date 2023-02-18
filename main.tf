module "network" {
  source             = "./modules/network"
  vpc_cidr           = "10.0.0.0/16"
  public_cidrs       = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidrs      = ["10.0.100.0/24", "10.0.101.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"] #keeping it really simple
  target_id          = module.compute.autoscaling_group
  certificate_arn    = module.dns.certificate_arn
}

module "compute" {
  source                 = "./modules/compute"
  web_sg                 = module.network.web_sg
  public_subnet          = module.network.public_subnet
  private_subnet         = module.network.private_subnet
  vpc_security_group_ids = module.network.vpc_security_group_ids
}

module "dns" {
  source           = "./modules/dns"
  domain_name      = "*.logicwizards.net"
  environment_name = "DEV"
  zone_name        = "logicwizards.net"
  record_name      = "quest.logicwizards.net"
  alias_name       = module.network.external-elb.dns_name
  alias_zone_id    = module.network.external-elb.zone_id
}