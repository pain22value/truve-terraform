variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "lifecycle_policy_json" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
