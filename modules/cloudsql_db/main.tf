resource "google_service_account_key" "sql_access" {
  service_account_id = "${var.client_service_account_email}"
}

resource "google_sql_user" "config-api" {
  name     = "${var.db_user}"
  instance = "${var.instance}"
  password = "${var.db_user_password}"
}

resource "google_sql_database" "config-api" {
  name     = "${var.db_name}"
  instance = "${var.instance}"

  depends_on = ["google_sql_database.config-api"]
}

// kubeconfig generated using credentials provided to module.
resource "local_file" "sql_access_key" {
  filename = "${var.render_dir}/sql-access-key.yaml"

  content = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name:  "${var.service_account_secret}"
data:
  instance-connection-name: "${base64encode(var.connection_name)}"
  service-account-key: "${google_service_account_key.sql_access.private_key}"
EOF
}
