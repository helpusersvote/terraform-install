output "path" {
  description = "Path where the kubeconfig was rendered"
  value       = "${local_file.kubeconfig.filename}"
}
