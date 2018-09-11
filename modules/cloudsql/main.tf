resource "google_service_account" "sql_access" {
  account_id   = "${var.client_service_account}"
  display_name = "Allows access to Help Users Vote SQL"
}

resource "google_project_iam_member" "sql_access_rights" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.sql_access.email}"
}

resource "google_sql_database_instance" "master" {
  name             = "${var.db_instance}"
  database_version = "POSTGRES_9_6"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}
