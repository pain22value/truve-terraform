locals {
  project_name = "truve"
  environment  = "dev"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    Terraform   = "true"
  }
}
