output "sql_service_account_email" {
  description = "Email of Google Service Account with access to connect to the database"
  value       = "${module.cloudsql.sql_service_account_email}"
}

output "sql_connection_name" {
  description = "Hostname provided by Cloud SQL to connect to a database instance"
  value       = "${module.cloudsql.connection_name}"
}

output "sql_instance" {
  description = "ID of the database instance within Cloud SQL."
  value       = "${module.cloudsql.instance_id}"
}

output "kubeconfig" {
  description = "Contents of the kubeconfig generated for the cluster"
  value       = "${module.kubeconfig.kubeconfig}"
  sensitive   = true
}
