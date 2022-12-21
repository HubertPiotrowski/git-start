module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_code}-rds"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id
  description = "Allow port 3306 TCP inbound to RDS instances within the VPC"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.external_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "rds-sg-out"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier             = "${var.env_code}-rds"
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = "admin"
  password               = local.rds_password
  port                   = "3306"
  db_name                = "mydb"
  create_random_password = false
  multi_az               = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  backup_retention_period = 1
  backup_window           = "03:00-04:00"

  create_db_subnet_group = true
  subnet_ids             = data.terraform_remote_state.level1.outputs.privatesub_id

  family               = "mysql8.0"
  major_engine_version = "8.0"

}
