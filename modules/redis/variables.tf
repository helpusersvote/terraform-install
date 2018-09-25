variable "render_dir" {
  description = "Path to directory where templated manifests can be outputted (defaults to path within module)"
  type        = "string"
  default     = ""
}

variable "config_path" {
  description = "Path to ConfigMap describing configuration for config-api (defaults to path within module)"
  type        = "string"
  default     = ""
}

variable "manifests_dir" {
  description = "Directory containing manifests used for deployment (defaults to path within module)"
  type        = "string"
  default     = ""
}

variable "kubeconfig" {
  description = "Path to kubeconfig used to authenticate with Kubernetes API server"
  type        = "string"
}

variable "image_repo" {
  description = "Image repository for redis"
  type        = "string"
  default     = "docker.io/bitnami/redis"
}

variable "image_tag" {
  description = "Image tag for redis"
  type        = "string"
  default     = "4.0.10-debian-9"
}

variable "disk_size" {
  description = "Size of disk to be attached. Kubernetes storage units should be used."
  type        = "string"
  default     = "200Gi"
}

variable "disk_label" {
  description = "Label selector used to specify PersistentVolume to use."
  type        = "string"
  default     = ""
}

variable "disk_config" {
  description = "Provider specific configuration which is appended to the defintion of a volume"
  type        = "string"
  default     = "emptyDir: {}"
}

variable "storage_class" {
  description = "Used to determine auto-provisioning, empty string disables"
  type        = "string"
  default     = ""
}

variable "last_resource" {
  description = "Allows dependency to be expressed to module"
  type        = "string"
  default     = ""
}

variable "do_destroy" {
  description = "Actually destroy manifests, otherwise will skip"
  default     = false
}
