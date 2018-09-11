variable "client_service_account" {
  description = "ID of the GCloud Service Account used to proxy to Cloud SQL"
  type        = "string"
}

variable "db_instance" {
  description = "ID of the Cloud SQL instance to create users and databases on"
  type        = "string"
}
