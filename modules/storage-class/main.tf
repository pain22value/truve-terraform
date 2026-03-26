resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = var.name

    annotations = merge(
      var.annotations,
      var.is_default_class ? {
        "storageclass.kubernetes.io/is-default-class" = "true"
      } : {}
    )
  }

  storage_provisioner = var.storage_provisioner
  reclaim_policy      = var.reclaim_policy
  volume_binding_mode = var.volume_binding_mode

  allow_volume_expansion = var.allow_volume_expansion
  mount_options          = var.mount_options
  parameters             = var.parameters
}
