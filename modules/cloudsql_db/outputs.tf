output "sql_access_key" {
  description = "Secret containing a key for given Service Account and the instance ID"
  value       = "${local_file.sql_access_key.filename}"
}
