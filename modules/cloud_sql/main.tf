resource "google_service_account" "sql_access" {
  account_id   = "${var.access_service_account_id}"
  display_name = "Allows access to Help Users Vote SQL"
}

resource "google_service_account_key" "sql_access" {
  service_account_id = "${google_service_account.sql_access.name}"
}

resource "google_project_iam_member" "sql_access_rights" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.sql_access.email}"
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

resource "google_sql_user" "config-api" {
  name     = "huv_user"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.db_user_password}"
}

resource "google_sql_database" "config-api" {
  name     = "huv-db"
  instance = "${google_sql_database_instance.master.name}"
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
