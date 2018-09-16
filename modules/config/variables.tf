variable "components" {
  description = "List of components to be deployed"
  type        = "list"
  default     = []
}

variable "config" {
  description = "ConfigMap describing configuration to be templated into manifests"
  type        = "string"
}

variable "manifest_dir" {
  description = "Directory containing manifests to be templated with values from ConfigMap"
  type        = "string"
}

variable "render_dir" {
  description = "Directiory to output templated manifests"
  type        = "string"
}

variable "vars" {
  description = "Additional variables to use in templates"
  type        = "map"
  default     = {}
}
