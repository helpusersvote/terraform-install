data "google_client_config" "current" {}

data "null_data_source" "values" {
  inputs = {
    full_sa = "${google_service_account.sql_access.account_id}@${data.google_client_config.current.project}.iam.gserviceaccount.com"
  }
}

resource "google_service_account" "sql_access" {
  account_id   = "${var.access_service_account_id}"
  display_name = "Allows access to Help Users Vote SQL"
}

resource "google_service_account_key" "sql_access" {
  service_account_id = "${google_service_account.sql_access.name}"
}

resource "google_service_account_iam_binding" "sql_access_rights" {
  service_account_id = "projects/${data.google_client_config.current.project}/serviceAccounts/${data.null_data_source.values.outputs["full_sa"]}"
  role               = "cloudsql.client"

  members = [
    "serviceAccount:${data.null_data_source.values.outputs["full_sa"]}",
  ]
}

resource "random_string" "sql_instance_id" {
  length  = 5
  upper   = false
  special = false
}

resource "google_sql_database_instance" "master" {
  name             = "helpusersvote-${random_string.sql_instance_id.result}"
  database_version = "POSTGRES_9_6"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "users" {
  name     = "huv_user"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.db_user_password}"
}

// kubeconfig generated using credentials provided to module.
resource "local_file" "sql_access_key" {
  filename = "${var.manifest_dir}/sql-access-key.yaml"

  content = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name:  "${var.service_account_secret}"
data:
  instance-connection-name: "${base64encode(google_sql_database_instance.master.connection_name)}"
  service-account-key: "${google_service_account_key.sql_access.private_key}"
EOF
}
