// Enable necessary APIs
resource "google_project_service" "cloud_sql" {
  service            = "sql-component.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_project_service" "cloud_sql_admin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_project_service" "resourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = "false"
}

resource "google_service_account" "sql_access" {
  account_id   = "${var.client_service_account}"
  display_name = "Allows access to Help Users Vote SQL"

  depends_on = ["google_project_service.iam"]
}

resource "google_project_iam_member" "sql_access_rights" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.sql_access.email}"

  depends_on = ["google_project_service.resourcemanager"]
}

resource "google_sql_database_instance" "master" {
  name             = "${var.db_instance}"
  database_version = "POSTGRES_9_6"
  region           = "us-central1"

  settings {
    tier = "${var.db_tier}"
  }

  depends_on = [
    "google_project_service.cloud_sql",
    "google_project_service.cloud_sql_admin",
  ]
}
