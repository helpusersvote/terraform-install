// objects created from Kubernetes manifests.
resource "null_resource" "objects" {
  count = "${length(var.manifest_dirs)}"

  provisioner "local-exec" {
    command = "${path.module}/scripts/manifests.sh create ${element(var.manifest_dirs, count.index)}"

    environment {
      KUBECONFIG = "${var.kubeconfig}"
      LAST       = "${var.last_resource}"
    }
  }

  provisioner "local-exec" {
    when       = "destroy"
    on_failure = "continue"
    command    = "${path.module}/scripts/manifests.sh destroy ${element(var.manifest_dirs, count.index)}"

    environment {
      KUBECONFIG = "${var.kubeconfig}"
    }
  }
}
