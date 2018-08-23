// objects created from Kubernetes manifests.
resource "null_resource" "objects" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_file.kubeconfig.filename} apply --recursive -f ${var.manifest_dir}"
  }

  provisioner "local-exec" {
    when       = "destroy"
    on_failure = "continue"
    command    = "kubectl --kubeconfig=${local_file.kubeconfig.filename} delete --recursive -f ${var.manifest_dir}"
  }
}

// kubeconfig generated using credentials provided to module.
resource "local_file" "kubeconfig" {
  filename = "${var.render_dir}/kubeconfig"

  content = <<EOF
apiVersion: v1
kind: Config
clusters:
- name: huv-cluster
  cluster:
    api-version: v1
    server: "${var.server}"
    certificate-authority-data: "${var.ca_certificate}"
users:
- name: huv-admin
  user:
    username: "${var.username}"
    password: "${var.password}"
    client-certificate-data: "${var.client_certificate}"
    client-key-data: "${var.client_key}"
contexts:
- name: huv
  context:
    cluster: huv-cluster
    user: huv-admin
current-context: huv
EOF
}
