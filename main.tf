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

// Ensure that required APIs are enabled.
resource "google_project_service" "kubernetes" {
  service            = "container.googleapis.com"
  disable_on_destroy = "false"
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

  depends_on = ["google_project_service.kubernetes"]
}

// Component specific modules

// config-api
module "config-api-gcp" {
  source = "git::https://github.com/usermirror/config-api.git//terraform/gcp?ref=5eea35d8279940e281d17e134c54419ba23d988d"

  gcloud_creds    = "${var.gcloud_creds}"
  cluster_project = "${var.cluster_project}"
  cluster_zone    = "${var.cluster_zone}"

  sql_service_account_email = "${module.cloudsql.sql_service_account_email}"
  sql_connection_name       = "${module.cloudsql.connection_name}"
  sql_instance_id           = "${module.cloudsql.instance_id}"
  sql_db_password           = "${var.sql_db_password}"
  domain                    = "${var.domain}"

  kubeconfig = "${module.kubeconfig.path}"
}

// redis stores analytics data about registrations
module "redis" {
  source = "./modules/redis"

  kubeconfig = "${module.kubeconfig.path}"
}

module "argo_tunnel" {
  source = "./modules/argo_tunnel"

  certs      = "${var.certs}"
  kubeconfig = "${module.kubeconfig.path}"
}

// collect and store metrics about running services
module "prometheus" {
  source = "./modules/prometheus"

  kubeconfig = "${module.kubeconfig.path}"
}

// Help Users Vote APIs
module "huv_apis" {
  source = "git::https://github.com/helpusersvote/apis.git//terraform?ref=v0.0.8"

  kubeconfig = "${module.kubeconfig.path}"
  domain     = "${var.domain}"
}

// generate kubeconfig to authenticate with Kubernete API server
module "kubeconfig" {
  source = "./modules/kubeconfig"

  render_dir = "${var.render_dir}"

  server             = "https://${google_container_cluster.huv_cluster.endpoint}"
  username           = "${google_container_cluster.huv_cluster.master_auth.0.username}"
  password           = "${google_container_cluster.huv_cluster.master_auth.0.password}"
  client_certificate = "${google_container_cluster.huv_cluster.master_auth.0.client_certificate}"
  client_key         = "${google_container_cluster.huv_cluster.master_auth.0.client_key}"
  ca_certificate     = "${google_container_cluster.huv_cluster.master_auth.0.cluster_ca_certificate}"
}

resource "random_string" "sql_instance_id" {
  length  = 5
  upper   = false
  special = false
}

// cloudsql creates a PostreSQL instance on Google Cloud.
module "cloudsql" {
  source = "./modules/cloudsql"

  client_service_account = "${var.sql_service_account_id}"
  db_instance            = "helpusersvote-${random_string.sql_instance_id.result}"
}
