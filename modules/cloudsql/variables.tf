variable "client_service_account" {
  description = "ID of the GCloud Service Account used to proxy to Cloud SQL"
  type        = "string"
}

variable "db_instance" {
  description = "ID of the Cloud SQL instance to create users and databases on"
  type        = "string"
}

variable "db_tier" {
  description = "Tier of the Cloud SQL instance"
  type        = "string"
  default     = "db-f1-micro"
}

variable "db_region" {
  description = "Region where database should be created"
  type        = "string"
}
