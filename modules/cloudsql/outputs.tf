output "sql_service_account_email" {
  description = "ID of the Service Account configured to access the instance"
  value       = "${google_service_account.sql_access.email}"
}

output "instance_id" {
  description = "ID of the Cloud SQL instance created"
  value       = "${google_sql_database_instance.master.name}"
}

output "connection_name" {
  description = "Host provided by Cloud SQL to connect to the database"
  value       = "${google_sql_database_instance.master.connection_name}"
}
