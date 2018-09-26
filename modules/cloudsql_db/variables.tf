variable "render_dir" {
  description = "Directory where Kubernetes manifests should be rendered"
  type        = "string"
}

variable "client_service_account_email" {
  description = "Email of the GCloud Service Account used to proxy to Cloud SQL"
  type        = "string"
}

variable "db_user" {
  description = "Name of the SQL user to be created/used with the database"
  type        = "string"
  default     = "db_user"
}

variable "db_name" {
  description = "Name of the database. If empty, no database is created."
  type        = "string"
  default     = ""
}

variable "instance" {
  description = "ID of the Cloud SQL instance to create users and databases on"
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

variable "connection_name" {
  description = "Host provided by Cloud SQL to connect to the database"
  type        = "string"
}
