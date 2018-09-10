// objects created from Kubernetes manifests.
resource "null_resource" "objects" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/manifests.sh create ${var.manifest_dir}"

    environment {
      KUBECONFIG = "${var.kubeconfig}"
      LAST       = "${var.last_resource}"
    }
  }

  provisioner "local-exec" {
    when       = "destroy"
    on_failure = "continue"
    command    = "${path.module}/scripts/manifests.sh destroy ${var.manifest_dir}"

    environment {
      KUBECONFIG = "${var.kubeconfig}"
    }
  }
}
