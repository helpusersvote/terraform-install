// generate hash of files in directory
data "external" "dir_hash" {
  count = "${length(var.manifest_dirs)}"

  program = [
    "${path.module}/scripts/hash-dir.sh",
    "${element(var.manifest_dirs, count.index)}",
  ]
}

// objects created from Kubernetes manifests.
resource "null_resource" "objects" {
  count = "${length(var.manifest_dirs)}"

  triggers {
    timestamp = "${timestamp()}"
    dir_hash  = "${data.external.dir_hash.*.result.hash[count.index]}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/manifests.sh create ${element(var.manifest_dirs, count.index)}"

    environment {
      RETRIES = "${var.retries}"
      WAIT    = "${var.wait}"

      KUBECONFIG = "${var.kubeconfig}"
      LAST       = "${var.last_resource}"
    }
  }

  provisioner "local-exec" {
    when       = "destroy"
    on_failure = "continue"

    command = <<EOF
	if [ "${var.do_destroy}" == "1" ]; then
		${path.module}/scripts/manifests.sh destroy ${element(var.manifest_dirs, count.index)}
        fi
EOF

    environment {
      KUBECONFIG = "${var.kubeconfig}"
    }
  }
}
