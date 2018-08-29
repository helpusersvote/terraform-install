variable "manifest_dir" {
  description = "Directory where Kubernetes manifests should be rendered"
  type        = "string"
}

variable "access_service_account_id" {
  description = "ID of the GCloud Service Account used to proxy to Google Cloud SQL databases"
  type        = "string"
}

variable "db_user_password" {
  description = "password to use with HUV vote database user"
  type        = "string"
}

variable "service_account_secret" {
  description = "Name of the Secret with the key to the GCloud Service Account  used to connect to SQL databases"
  type        = "string"
  default     = "sql-access"
}
