locals {
  name = "pet-adoption"
}

module "bastion" {
  source          = "./module/bastion"
  redhat          = "ami-07d4917b6f95f5c2a"
  pub1-name = module.vpc.pubsn-1-id
  bastion-sg = module.security-group.bastion-sg-id
  pub-key = module.keypair.public-key-id
  prv-key = module.keypair.private-key-pem
  bastion-server-name = "${local.name}-bastion-server"
}

module "keypair" {
  source       = "./module/keypair"
  prv_file = "${local.name}-private-key"
  pub_file = "${local.name}-public-key"
}

module "nexus" {
  source       = "./modules/nexus"
  redhat       = "ami-07d4917b6f95f5c2a"
  pubsn1 = module.vpc.pubsn1-1-id
  pub-key = module.keypair.public-key-id
  nexus-sg = module.security-group.nexus-sg-id
  nexus-server-name = "${local.name}-nexus-server"
  nexus-ip = module.nexus.nexus-ip
  nr-user-licence = var.nr_user_licence
  nr-acct-id =var.nr_acct_id
  nr-region = "EU"
  pub-subnets = [module.vpc.pubsn-1-id, module.vpc.pubsn-2-id]
  cert-arn = data.aws_acm_certificate.arn
}

module "production-asg" {
  source        = "./module/production-asg"
  redhat = "ami-07d4917b6f95f5c2a"
  docker-sg = module.security-group.docker-sg-id
  pub-key = module.keypair.public-key-id
  nexus-ip = module.nexus.nexus-ip
  nr-user-licence= var.nr_user_licence
  nr-acct-id = var.nr_acct_id
  nr-region= "EU"
  prod-name= "${local.name}-docker-server"
  vpc-zone-id= [module.vpc.prvsub-1-id, module.vpc.prvsub-2-id]
  lb-target-grp-arn = module.production-lb.alb-production-arn
}

module "production-lb" {
  source = "./module/production-lb"
  docker-sg = module.security-group.docker-sg-id
  pub-subnets = [module.vpc.pubsn-1-id, module.vpc.pubsn2-1-id]
  port-http = 80
  port-https = 443
  cert-arn = data.aws_acm_certificate.certificate.arn
  pet-vpc-id = module.vpc.vpc-id
}

module "rds" {
  source       = "./module/rds"
  rds-sub-group = "rds_subgroup" #can be given any name
  rds-subnets   = [module.vpc.prvsub-1-id, module.vpc.prvsub-2-id]
  db-name      = "petclinic"
  db-username  = data.vault_generic_secret.vault-secret.data["username"]
  db-password  = data.vault_generic_secret.vault-secret.data["password"]
  rds-sg       = [module.security-group.rds-sg]
}

module "route53" {
  source = "./module/route53"
  domain_name = "dobetabeta.shop"
  nexus_domain_name = "nexus.dobetabeta.shop"
  nexus_lb_dns_name = module.nexus.nexus-dns
  nexus_lb_zone_id = module.nexus.nexuxus.zone-id
  sonarqube_domain_name = "sonarqube.dobetabeta.shop"
  sonarqube_lb_dns_name = module.sonarqube.sonarqube-dns
  sonarqube_lb_zone_id = module.sonarqube.sonarqube-zone-id
  prod_domain_name = "prod.dobetabeta.shop"
  prod_lb_dns_name = module.production-lb.alb-production-dns
  prod_lb_zone_id = module.production-lb.alb-production-zoneid
  stage_domain_name = "stage.dobetabeta.shop"
  stage_lb_dns_name = module.stage-lb.alb-stage-dns
  stage_lb_zone_id = module.stage-lb.alb-stage-zoneid
}

module "security-group" {
  source = "./module/security-group"
  pet-vpc-id = module.vpc.vpc-id
}

module "sonarqube" {
  source = "./module/sonarqube"
  ubuntu = "ami-0c38b837cd80f13bb"
  pub-key = module.keypair.public-key-id
  sonarqube-sg = module.security-group.sonarqube-sg-id
  pubsn1 = module.vpc.pubsn1-1-id
  sonarqube-server-name = "${local.name}-sonarqube-server"
  pub-subnets = [module.vpc.pubsn-1-id, module.vpc.pubsn-2-id]
  cert-arn = data.aws_acm_certificate.certificate.arn
  sonarqube-elb = "${local.name}-sonarqube-elb"
  nr-user-licence = var.nr_user_licence
  nr-acct-id = var.nr_acct_id
  nr-region = "EU"
}

module "stage-asg" {
  source        = "./module/stage-asg"
  redhat = "ami-07d4917b6f95f5c2a"
  docker-sg = module.security-group.docker-sg-id
  pub-key = module.keypair.public-key-id
  nexus-ip = module.nexus.nexus-ip
  nr-user-licence= var.nr_user_licence  # Replaced with variable
  nr-acct-id = var.nr_acct_id # Replaced with variable
  nr-region = "EU"
  stage-name = "${local.name}-docker-stage-server"
  vpc-zone-id = [module.vpc.prvsub-1-id, module.vpc.prvsub-2-id]
  lb-target-grp-arn = module.stage-lb.alb-stage-arn
}

module "stage-lb" {
  source = "./module/stage-lb"
  docker-sg = module.security-group.docker-sg-id
  pub-subnets = [module.vpc.pubsn-1-id, module.vpc.pubsn2-1-id]
  port-http = 80
  port-https = 443
  cert-arn = data.aws_acm_certificate.certificate.arn
  pet-vpc-id = module.vpc.vpc-id
}

module "vpc" {
  source = "./module/vpc"
  vpc-name = "${local.name}-vpc"
  pub1-name = "${local.name}-pub1"
  pub2-name = "${local.name}-pub2"
  prv1-name = "${local.name}-prv1"
  prv2-name = "${local.name}-prv2"
  az-1 = "eu-west-1a"
  az-2 = "eu-west-1b"
  igw = "${local.name}-igw"
  eip = "${local.name}-eip"
  nat = "${local.name}-nat"
  pub-rt = "${local.name}-pub-rt"
  prv-rt = "${local.name}-prv-rt"
}



module "security-group" {
  source = "./module/security-group"
  pet-vpc-id = module.vpc.vpc-id
}

