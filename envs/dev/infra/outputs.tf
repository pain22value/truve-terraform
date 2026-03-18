output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "backend_ecr_repository_url" {
  value = module.ecr_backend.repository_url
}

output "frontend_ecr_repository_url" {
  value = module.ecr_frontend.repository_url
}
