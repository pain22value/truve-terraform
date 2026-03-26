variable "name" {
  description = "StorageClass name"
  type        = string
}

variable "storage_provisioner" {
  description = "Provisioner for the StorageClass"
  type        = string
  default     = "ebs.csi.aws.com"
}

variable "reclaim_policy" {
  description = "Reclaim policy for dynamically provisioned volumes"
  type        = string
  default     = "Delete"

  validation {
    condition     = contains(["Delete", "Retain"], var.reclaim_policy)
    error_message = "reclaim_policy must be either Delete or Retain."
  }
}

variable "volume_binding_mode" {
  description = "Volume binding mode"
  type        = string
  default     = "WaitForFirstConsumer"

  validation {
    condition = contains(
      ["Immediate", "WaitForFirstConsumer"],
      var.volume_binding_mode
    )
    error_message = "volume_binding_mode must be either Immediate or WaitForFirstConsumer."
  }
}

variable "allow_volume_expansion" {
  description = "Whether to allow PVC expansion"
  type        = bool
  default     = true
}

variable "is_default_class" {
  description = "Whether this StorageClass should be the default"
  type        = bool
  default     = false
}

variable "parameters" {
  description = "Parameters for the StorageClass"
  type        = map(string)
  default     = {}
}

variable "mount_options" {
  description = "Mount options for the StorageClass"
  type        = list(string)
  default     = []
}

variable "annotations" {
  description = "Additional annotations for the StorageClass"
  type        = map(string)
  default     = {}
}
