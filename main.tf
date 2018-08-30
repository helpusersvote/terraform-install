// google provider allows the use of Google Cloud resources
//
// Credentials can be downloaded at https://console.cloud.google.com/apis/credentials/serviceaccountkey.
provider "google" {
  version = "~> 1.17"

  credentials = "${var.gcloud_creds}"
  project     = "${var.cluster_project}"
  region      = "${var.cluster_zone}"
}

// local provider writes and reads files from disk
provider "local" {
  version = "~> 1.1"
}

// null provider allows abitrary operations (mostly for using kubectl)
provider "null" {
  version = "~> 1.0"
}

// random provider creates randomized values for use in ID creation and testing.
provider "random" {
  version = "~> 2.0"
}

// external allows custom commands to be run to examine manifest and cluster state.
provider "external" {
  version = "~> 1.0"
}

// huv_cluster is GKE cluster for use with Help Users Vote.
resource "google_container_cluster" "huv_cluster" {
  name = "${var.cluster_name}"
  zone = "${var.cluster_zone}"

  initial_node_count = 1

  master_auth {
    username = "${var.cluster_username}"
    password = "${var.cluster_password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

// kubernetes allows syncing manifests to the Kubernetes API server.
module "kubernetes" {
  source = "./modules/kubernetes"

  manifest_dir = "${path.module}/manifests"
  render_dir   = "${var.render_dir}"

  server             = "https://${google_container_cluster.huv_cluster.endpoint}"
  username           = "${google_container_cluster.huv_cluster.master_auth.0.username}"
  password           = "${google_container_cluster.huv_cluster.master_auth.0.password}"
  client_certificate = "${google_container_cluster.huv_cluster.master_auth.0.client_certificate}"
  client_key         = "${google_container_cluster.huv_cluster.master_auth.0.client_key}"
  ca_certificate     = "${google_container_cluster.huv_cluster.master_auth.0.cluster_ca_certificate}"

  last_resource = "${module.cloud_sql.last_resource}"
}

// cloud_sql provides persistence backed by PostreSQL on Google Cloud.
module "cloud_sql" {
  source = "./modules/cloud_sql"

  manifest_dir              = "${path.module}/manifests"
  access_service_account_id = "${var.sql_service_account_id}"
  db_user_password          = "${var.sql_db_password}"
}
