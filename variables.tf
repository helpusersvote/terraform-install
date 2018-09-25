variable "render_dir" {
  description = "Path to output generated Kubernetes manifests"
  type        = "string"
  default     = "./generated"
}

variable "gcloud_creds" {
  description = "Credentials used to authenticate with Google Cloud and create a cluster. Credentials can be downloaded at https://console.cloud.google.com/apis/credentials/serviceaccountkey."
  type        = "string"
  default     = ""
}

variable "cluster_project" {
  description = "Gcloud project to deploy cluster in."
  type        = "string"
}

variable "cluster_zone" {
  description = "Gcloud zone to deploy cluster in."
  type        = "string"
  default     = "us-west1"
}

variable "cluster_name" {
  description = "Name for the GKE cluster"
  type        = "string"
  default     = "help-users-vote"
}

variable "cluster_username" {
  description = "Username to connect to Kubernetes API Server"
  type        = "string"
  default     = "huv-user"
}

variable "cluster_password" {
  description = "Password to connect to Kubernetes API Server (must be at least 16 char)"
  type        = "string"
}

variable "sql_service_account_id" {
  description = "ID of the Google Cloud Service Account used to access SQL database instances."
  type        = "string"
  default     = "huv-sql-access"
}

variable "sql_db_password" {
  description = "Password for the SQL user used to perform writes."
  type        = "string"
  default     = "changeme"
}

variable "sql_db_tier" {
  description = "Tier of the Cloud SQL instance"
  type        = "string"
  default     = "db-f1-micro"
}

variable "certs" {
  description = "Path to directory containing CloudFlare Argo certificates formated as Secrets"
  type        = "string"
  default     = ""
}

variable "domain" {
  description = "Domain which is used in configuring ingresses"
  type        = "string"
  default     = "staging.helpusersvote.com"
}

variable "google_api_key" {
  description = "Google API Key to use the Civic Information API"
  type        = "string"
  default     = ""
}

variable "initial_node_count" {
  description = "Initial count of nodes for Google Kubernetes cluster"
  type        = "string"
  default     = 2
}

variable "events_api_read_key" {
  description = "Events API read key for the Dashboard"
  type        = "string"
  default     = ""
}

variable "redis_disk_size" {
  description = "Size (in GB) of the disk created for Redis"
  type        = "string"
  default     = "250"
}

variable "prometheus_disk_size" {
  description = "Size (in GB) of the disk created for Prometheus"
  type        = "string"
  default     = "250"
}

variable "do_destroy" {
  description = "Actually destroy manifests, otherwise will skip"
  default     = false
}
