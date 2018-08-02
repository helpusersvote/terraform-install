variable "manifest_dir" {
  description = "Path to a directory containing manifests to be applied to the cluster"
  type = "string"
}

variable "render_dir" {
  description = "Directory where rendered manifests should be sent"
  type = "string"
}

variable "server" {
  description = "Kubernetes API server URL (http/https)"
  type = "string"
  default = ""
}

variable "username" {
  description = "Username used to authenticate with Kubernetes API server"
  type = "string"
  default = ""
}

variable "password" {
  description = "Password used to authenticate with Kubernetes API server"
  type = "string"
  default = ""
}

variable "client_certificate" {
  description = "Base64 encoded x509 Client certificate to authenticate with Kubernetes API server."
  type = "string"
  default = ""
}

variable "client_key" {
  description = "Base64 encoded x509 Client key to authenticate with Kubernetes API server."
  type = "string"
  default = ""
}

variable "ca_certificate" {
  description = "Base64 encoded x509 Certifiate Authority certificate to authenticate with Kubernetes API server."
  type = "string"
  default = ""
}
