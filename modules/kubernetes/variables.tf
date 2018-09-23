variable "manifest_dirs" {
  description = "Paths of directories containing manifests to be applied to the cluster"
  type        = "list"
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

variable "do_destroy" {
  description = "Actually destroy manifests, otherwise will skip"
  default     = false
}
