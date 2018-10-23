// google provider allows the use of Google Cloud resources
//
// Credentials can be downloaded at https://console.cloud.google.com/apis/credentials/serviceaccountkey.
provider "google" {
  version = "~> 1.17"

  credentials = "${var.gcloud_creds}"
  project     = "${var.cluster_project}"
  region      = "${var.cluster_region}"
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

// Get list of zones for the region
data "google_compute_zones" "available" {}

// pool configuration
locals {
  zone1 = "${element(data.google_compute_zones.available.names, 0)}"
  zone2 = "${element(data.google_compute_zones.available.names, 1)}"
  zone3 = "${element(data.google_compute_zones.available.names, 2)}"

  oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}

// huv_cluster is regional GKE cluster for use with Help Users Vote.
resource "google_container_cluster" "huv_cluster" {
  name        = "${var.cluster_name}"
  description = "Hosts workloads related to Help Users Vote."

  region = "${var.cluster_region}"

  additional_zones = [
    "${local.zone1}",
    "${local.zone2}",
    "${local.zone3}",
  ]

  network            = "projects/${var.cluster_project}/global/networks/default"
  min_master_version = "1.10.7-gke.6"

  master_auth {
    username = "${var.cluster_username}"
    password = "${var.cluster_password}"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  node_pool {
    name = "default-pool"
  }

  depends_on = ["google_project_service.kubernetes"]
}

// create cluster nodes
resource "google_container_node_pool" "primary" {
  name    = "${var.cluster_name}-primary"
  region  = "${var.cluster_region}"
  cluster = "${google_container_cluster.huv_cluster.name}"

  initial_node_count = 2
  version            = "1.10.7-gke.6"

  autoscaling {
    min_node_count = 2
    max_node_count = 2
  }

  node_config {
    oauth_scopes = "${local.oauth_scopes}"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

// Component specific modules

// config-api
module "config-api-gcp" {
  source = "git::https://github.com/usermirror/config-api.git//terraform/gcp?ref=ad953041413e4ea108e47f5a7fce6b7d509728c4"

  gcloud_creds    = "${var.gcloud_creds}"
  cluster_project = "${var.cluster_project}"
  cluster_zone    = "${var.cluster_region}"

  sql_service_account_email = "${module.cloudsql.sql_service_account_email}"
  sql_connection_name       = "${module.cloudsql.connection_name}"
  sql_instance_id           = "${module.cloudsql.instance_id}"
  sql_db_password           = "${var.sql_db_password}"
  domain                    = "${var.domain}"

  kubeconfig = "${module.kubeconfig.path}"
}

// create disk to provide redis persistence
resource "google_compute_disk" "redis" {
  name  = "${var.cluster_name}-redis-data"
  size  = "${var.redis_disk_size}"
  type  = "pd-ssd"
  zone  = "${local.zone1}"
  image = ""

  labels {
    environment = "${var.cluster_name}"
  }
}

// redis stores analytics data about registrations
module "redis" {
  source = "./modules/redis"

  kubeconfig = "${module.kubeconfig.path}"

  disk_size  = "${google_compute_disk.redis.size}G"
  disk_label = "${google_compute_disk.redis.name}"

  disk_config = <<EOF
gcePersistentDisk:
  pdName: ${google_compute_disk.redis.name}
  fsType: ext4
EOF
}

# Contour is an Evoy powered Ingress operator
module "contour" {
  source = "./modules/contour"

  certs      = "${var.certs}"
  kubeconfig = "${module.kubeconfig.path}"
}

# Deprecated: eventually should be removed
module "argo_tunnel" {
  source = "./modules/argo_tunnel"

  certs      = "${var.certs}"
  kubeconfig = "${module.kubeconfig.path}"
}

// create disk to provide Prometheus persistence
resource "google_compute_disk" "prometheus" {
  name  = "${var.cluster_name}-prometheus-data"
  size  = "${var.prometheus_disk_size}"
  type  = "pd-ssd"
  zone  = "${local.zone1}"
  image = ""

  labels {
    environment = "${var.cluster_name}"
  }
}

// collect and store metrics about running services
module "prometheus" {
  source = "./modules/prometheus"

  kubeconfig = "${module.kubeconfig.path}"

  disk_size  = "${google_compute_disk.prometheus.size}G"
  disk_label = "${google_compute_disk.prometheus.name}"

  disk_config = <<EOF
gcePersistentDisk:
  pdName: ${google_compute_disk.prometheus.name}
  fsType: ext4
EOF
}

// Help Users Vote APIs
module "huv_apis" {
  source = "git::https://github.com/helpusersvote/apis.git//terraform?ref=cddeb2f183622579769d0c2161d7f47b4c32efe8"

  kubeconfig          = "${module.kubeconfig.path}"
  domain              = "${var.domain}"
  environment         = "${var.environment}"
  google_api_key      = "${var.google_api_key}"
  events_api_read_key = "${var.events_api_read_key}"
  segment_write_key   = "${var.segment_write_key}"
  sentry_dsn          = "${var.sentry_dsn}"
}

// ensure node_pool is ready
locals {
  nodes_ready = "${google_container_node_pool.primary.name=="" ? "" : ""}"
}

// generate kubeconfig to authenticate with Kubernete API server
module "kubeconfig" {
  source = "./modules/kubeconfig"

  render_dir = "${var.render_dir}"

  server             = "https://${google_container_cluster.huv_cluster.endpoint}${local.nodes_ready}"
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
  db_region              = "${var.cluster_region}"
  db_tier                = "${var.sql_db_tier}"
  db_instance            = "${var.cluster_name}-${random_string.sql_instance_id.result}"
}
