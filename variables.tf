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
