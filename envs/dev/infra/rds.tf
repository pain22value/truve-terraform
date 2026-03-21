module "rds" {
  source = "../../../modules/rds"

  identifier = "dev-mysql"

  db_name  = "truvedb"
  username = "admin"
  password = "truve1234!"

  major_engine_version = "8.0"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.database_subnets

  admin_security_group_id    = module.ops_ec2.security_group_id
  eks_node_security_group_id = module.eks.node_security_group_id

  multi_az                = true
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Project     = "truve"
    Environment = "dev"
    Terraform   = "true"
  }
}
