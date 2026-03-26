output "name" {
  description = "Created StorageClass name"
  value       = kubernetes_storage_class_v1.this.metadata[0].name
}

output "id" {
  description = "Created StorageClass id"
  value       = kubernetes_storage_class_v1.this.id
}
