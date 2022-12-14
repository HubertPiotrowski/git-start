module "rds" {
  source = "../modules/rds"

  env_code              = var.env_code
  subnet_ids            = data.terraform_remote_state.level1.outputs.privatesub_id
  vpc_id                = data.terraform_remote_state.level1.outputs.vpc_id
  source_security_group = module.asg.security_group_id
  rds_password          = local.rds_password
}
