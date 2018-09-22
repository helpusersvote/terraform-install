output "manifest_state" {
  description = "List of Terraform generated hashes for each template directory"
  value       = "${template_dir.kube_manifests.*.id}"
}

output "dirs" {
  description = "Directories which were templated into"
  value       = "${local.output_dirs}"
}
