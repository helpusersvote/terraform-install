output "path" {
  description = "Path where the kubeconfig was rendered"
  value       = "${local_file.kubeconfig.filename}"
}

output "kubeconfig" {
  description = "Contents of the kubeconfig generated for the cluster"
  value       = "${local.kubeconfig}"
  sensitive   = true
}
