variable "manifest_dir" {
  description = "Path to a directory containing manifests to be applied to the cluster"
  type        = "string"
}

variable "kubeconfig" {
  description = "Path to kubeconfig used to authenticate with API server"
  type        = "string"
}

variable "last_resource" {
  description = "Used to created dependency on previous step"
  type        = "string"
  default     = ""
}
